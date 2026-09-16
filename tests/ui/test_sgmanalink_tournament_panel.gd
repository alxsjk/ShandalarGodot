extends GutTest
## The hall remains navigable at the smallest supported desktop playtest size.

var _had_folder := false
var _saved_folder: Variant


func before_each() -> void:
	_had_folder = Settings.has_value(GamePaths.KEY_TOURNAMENTS)
	_saved_folder = Settings.get_value(GamePaths.KEY_TOURNAMENTS, null) if _had_folder else null


func after_each() -> void:
	if _had_folder: Settings.set_value(GamePaths.KEY_TOURNAMENTS, _saved_folder)
	else: Settings.clear_value(GamePaths.KEY_TOURNAMENTS)


func test_tournament_setup_is_opt_in_and_uses_three_deck_policies() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 600)
	add_child_autofree(viewport)
	var lobby := SgLobby.new()
	viewport.add_child(lobby)
	lobby._show_page("tournament")
	for i in 6: await get_tree().process_frame
	assert_eq(lobby._tournament_panel._policy.item_count, 3)
	assert_eq(lobby._tournament_panel._wins.item_count, 3)
	assert_eq(lobby._tournament_panel._limit.item_count, 19)
	assert_eq(lobby._tournament_panel._limit.get_item_text(18), "20 players")
	assert_false(lobby._tournament_panel._deck_area.visible)
	lobby._tournament_panel._policy.select(1)
	lobby._tournament_panel._policy.item_selected.emit(1)
	assert_true(lobby._tournament_panel._deck_area.visible)
	assert_null(lobby.service)
	assert_null(lobby._discovery)
	assert_false(lobby.client._wanted)
	assert_lte(lobby._window.position.x + lobby._window.size.x, 960.0)
	assert_lte(lobby._window.position.y + lobby._window.size.y, 600.0)
	assert_eq(lobby._content_scroll.horizontal_scroll_mode, ScrollContainer.SCROLL_MODE_DISABLED)


func test_cancelled_tables_do_not_claim_to_be_in_progress() -> void:
	var panel := SgTournamentPanel.new()
	add_child_autofree(panel)
	panel._view = {"phase": "cancelled", "tables": [], "entrants": [{"id": 1, "name": "Azure"}, {"id": 2, "name": "Amber"}],
		"rounds": [[{"id": 9, "players": [1, 2], "wins": [0, 0], "draws": 0, "winner": 0, "game": 1, "status": "playing"}]]}
	panel._build_rounds()
	var labels := PackedStringArray()
	for label in panel.find_children("*", "Label", true, false): labels.append(label.text)
	assert_true(labels.has("Cancelled · no further games"))
	assert_false("\n".join(labels).contains("in progress"))


func test_tournament_setup_exposes_welcome_and_local_save_folder() -> void:
	var panel := _panel()
	panel.present({}, false, false, true)
	assert_not_null(panel.find_child("TournamentName", true, false))
	assert_not_null(panel.find_child("TournamentWelcomeEdit", true, false))
	assert_not_null(panel.find_child("TournamentSaveFolder", true, false))


func test_welcome_is_readable_literal_text_for_new_and_registered_players() -> void:
	var view := _view(_event())
	view.organiser = false
	view.config.welcome = "Welcome, duelists! [b]This is plain text[/b] — good luck."
	var panel := _panel()
	for entrant in [0, 1]:
		view.you = entrant
		panel.present(view, true, false, false)
		for i in 6: await get_tree().process_frame
		var message := panel.find_child("TournamentWelcome", true, false) as Label
		assert_not_null(message)
		assert_eq(message.text, view.config.welcome)
		assert_gt(message.autowrap_mode, TextServer.AUTOWRAP_OFF)
		assert_lte(message.get_global_rect().end.x, 920.0)
		assert_lte(panel.size.x, 920.0)
	view.config.erase("welcome")
	panel.present(view, true, false, false)
	assert_null(panel.find_child("TournamentWelcome", true, false))
	for i in 3: await get_tree().process_frame


func test_folder_selection_is_remembered_refreshes_saved_events_and_stays_local() -> void:
	var folder := "user://tournament-tests/selected folder " + Crypto.new().generate_random_bytes(8).hex_encode()
	var event := SgTournament.new()
	assert_eq(event.configure({"name": "Saved welcome cup", "welcome": "Welcome back!", "limit": 8,
		"wins": 1, "policy": "own", "decks": []}, 42), "")
	assert_eq(SgTournamentStore.save(event, folder), OK)
	var panel := _panel()
	panel.present({}, false, false, true)
	var picker := panel._make_folder_picker()
	assert_eq(picker.file_mode, FileDialog.FILE_MODE_OPEN_DIR)
	assert_eq(picker.access, FileDialog.ACCESS_FILESYSTEM)
	var absolute := ProjectSettings.globalize_path(folder)
	picker.dir_selected.emit(absolute)
	assert_eq(GamePaths.tournaments_folder(), absolute)
	assert_eq(panel._folder_edit.text, absolute)
	var resume := panel._saved_events.get_child(0) as Button
	assert_not_null(resume)
	assert_true(resume.text.contains("Saved welcome cup"))
	var events: Array = []
	panel.host_requested.connect(func(options: Dictionary, path: String) -> void: events.append([options, path]))
	resume.pressed.emit()
	assert_eq(events.size(), 1)
	assert_eq(events[0][1], absolute.path_join(event.id + ".json"))
	panel._welcome_edit.text = "Have fun, everyone!"
	panel.find_child("TournamentOpenRegistration", true, false).pressed.emit()
	assert_eq(events.size(), 2)
	assert_eq(events[1][0].welcome, "Have fun, everyone!")
	assert_false(JSON.stringify(events[1][0]).contains(absolute), "host path must not enter shared config")
	panel._folder_edit.text = "relative/saves"
	panel.find_child("TournamentOpenRegistration", true, false).pressed.emit()
	assert_eq(events.size(), 2, "an invalid folder must not open a host")
	assert_eq(GamePaths.tournaments_folder(), absolute)
	var reopened := _panel()
	reopened.present({}, false, false, true)
	assert_eq(reopened._folder_edit.text, absolute)
	for i in 6: await get_tree().process_frame
	assert_lte(panel.size.x, 920.0, "long save paths scroll inside their field")
	assert_lte(panel._folder_edit.get_global_rect().end.x, 920.0)
	DirAccess.remove_absolute(folder.path_join(event.id + ".json"))
	DirAccess.remove_absolute(folder)


func _event() -> SgTournament:
	var event := SgTournament.new()
	assert_eq(event.configure({"name": "Twenty Player Cup", "limit": 20, "wins": 1, "policy": "fixed",
		"decks": [{"name": "White Knights", "cards": Array(StarterDecks.WHITE_KNIGHTS), "sideboard": []}]}, 4242), "")
	for i in 20:
		var pid := event.register("Long Player %02d (Guest %d)" % [i + 1, i + 1], str(i).sha256_text())
		event.set_ready(pid, true)
	event.draw_round()
	return event


func _view(event: SgTournament) -> Dictionary:
	var server := SgLocalServer.new()
	add_child_autofree(server)
	var host := SgTournamentHost.new()
	host.event = event
	host.organiser = 99
	server.add_child(host)
	return host.view(99)


func _panel() -> SgTournamentPanel:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 600)
	add_child_autofree(viewport)
	var scroll := ScrollContainer.new()
	scroll.size = Vector2(920, 560)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	viewport.add_child(scroll)
	var panel := SgTournamentPanel.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(panel)
	return panel


func test_twenty_player_graph_is_connected_non_overlapping_and_preserves_exploration() -> void:
	var event := _event()
	for round_index in 5:
		for pair: Dictionary in event.rounds.back():
			if pair.status == "bye": continue
			for pid: int in pair.players: event.set_ready(pid, true)
			event.begin_game(pair.id)
			event.record_game(pair.id, pair.game, 0)
		if event.phase == "complete": break
		event.draw_round()
	var view := _view(event)
	var panel := _panel()
	panel.present(view, true, false, true)
	assert_eq(panel._section, "standings", "a completed tournament opens its final score table")
	var table := panel.find_child("TournamentStandings", true, false) as Tree
	assert_not_null(table)
	var count := 0
	var item := table.get_root().get_first_child()
	while item != null:
		count += 1
		item = item.get_next()
	assert_eq(count, 20)
	panel._choose_section("advancement")
	for i in 6: await get_tree().process_frame
	var graph := panel._graph
	assert_eq(graph._canvas.graph.nodes.size(), 31)
	assert_eq(graph._canvas.graph.links.size(), 30)
	for a: Dictionary in graph._canvas.graph.nodes:
		var box: Rect2 = graph._canvas.boxes[a.id]
		assert_true(Rect2(Vector2.ZERO, graph._canvas.extent).encloses(box))
		for b: Dictionary in graph._canvas.graph.nodes:
			if a.id != b.id: assert_false(box.intersects(graph._canvas.boxes[b.id]), "draw nodes never overlap")
	graph._fit_picker.select(2)
	graph._fit_picker.item_selected.emit(2)
	for i in 3: await get_tree().process_frame
	assert_lte(graph._canvas.custom_minimum_size.x, graph._scroll.size.x)
	assert_lte(graph._canvas.custom_minimum_size.y, graph._scroll.size.y)
	var elided := graph._canvas._elide("An exceptionally long tournament player name", 17, 192)
	assert_true(elided.ends_with("…"))
	assert_lte(graph._canvas.face.get_string_size(elided, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x, 192.0)
	graph._zoom_by(0.1)
	graph.follow(17)
	var saved := graph.capture_state()
	var previous_id := graph.get_instance_id()
	view.revision += 1
	panel.present(view, true, false, true)
	assert_eq(panel._graph.get_instance_id(), previous_id, "ACK-only updates do not rebuild the diagram")
	view.entrants[0].connected = true
	panel.present(view, true, false, true)
	for i in 6: await get_tree().process_frame
	assert_eq(panel._graph._canvas.selected, 17)
	assert_almost_eq(panel._graph._canvas.zoom, saved.zoom, 0.001)
	assert_lte(panel.size.x, 920.0)
	panel._choose_section("overview")
	panel._choose_section("advancement")
	for i in 4: await get_tree().process_frame
	assert_eq(panel._graph._canvas.selected, 17, "tab navigation keeps the selected path")


func test_all_tournament_tabs_work_without_network_side_effects() -> void:
	var view := _view(_event())
	var panel := _panel()
	watch_signals(panel)
	panel.present(view, true, false, true)
	for section in ["advancement", "standings", "players", "entry", "overview"]:
		var button := panel.find_child("TournamentTab_" + section, true, false) as Button
		assert_not_null(button)
		button.pressed.emit()
		assert_eq(panel._section, section)
		for i in 3: await get_tree().process_frame
		assert_lte(panel.size.x, 920.0)
	assert_signal_not_emitted(panel, "action_requested")
	assert_signal_not_emitted(panel, "host_requested")
