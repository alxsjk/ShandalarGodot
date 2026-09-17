class_name SgTournamentPanel
extends VBoxContainer
## [QoL] Shared Tournament Hall and organiser Master Panel. Only public table
## progress is displayed; another entrant's private deck/hand is never requested.

signal host_requested(options: Dictionary, restore_path: String)
signal action_requested(action: Dictionary)
var _view: Dictionary = {}
var _snapshot: Dictionary = {}
var _online := false
var _busy := false
var _can_host := false
var _setup_built := false
var _catalog: Array = []
var _approved: Array = []
var _name_edit: LineEdit
var _welcome_edit: LineEdit
var _folder_edit: LineEdit
var _folder_notice: Label
var _saved_events: VBoxContainer
var _listed_folder := ""
var _limit: OptionButton
var _wins: OptionButton
var _policy: OptionButton
var _approved_text: Label
var _deck_area: VBoxContainer
var _notice: Label
var _confirm := ""
var _reviewing := false
var _picker_query := ""
var _picker_selected: Dictionary = {}
var _recovery_draft := ""
var _section := "overview"
var _graph: SgTournamentBracket
var _graph_state: Dictionary = {}
var _selected_entrant := 0
var _bot_draft: Dictionary = {}


func present(value: Dictionary, online: bool, busy: bool, can_host: bool) -> void:
	if value.get("id", "") != _view.get("id", ""):
		_confirm = ""
		_picker_query = ""
		_picker_selected.clear()
		_recovery_draft = ""
		_reviewing = false
		_graph = null
		_graph_state.clear()
		_selected_entrant = 0
		_section = "overview" if value.get("organiser", false) else "entry"
	if value.get("phase", "") == "complete" and _view.get("phase", "") != "complete": _section = "standings"
	_view = value.duplicate(true)
	_online = online
	_busy = busy
	_can_host = can_host
	var snapshot := value.duplicate(true)
	snapshot.erase("revision")
	# Life/phase-only traffic does not rebuild a diagram or score table the
	# player is exploring. Their content comes from the round ledger.
	if _section != "overview": snapshot.erase("tables")
	if snapshot != _snapshot or get_child_count() == 0:
		var focus_name := ""
		var caret := 0
		var focus := get_viewport().gui_get_focus_owner() if is_inside_tree() else null
		if focus is LineEdit and is_ancestor_of(focus):
			focus_name = focus.name
			caret = focus.caret_column
		_snapshot = snapshot
		if value.is_empty():
			if not _setup_built: _build_setup()
		else:
			_setup_built = false
			_clear()
			_build_hall()
		if not focus_name.is_empty():
			var replacement := find_child(focus_name, true, false) as LineEdit
			if replacement != null:
				replacement.grab_focus()
				replacement.caret_column = caret
	for button in find_children("*", "Button", true, false):
		if button.has_meta("t_network"): button.disabled = not online or busy or not button.get_meta("available", true)
		if button.has_meta("t_host"): button.disabled = not can_host or busy
	if _setup_built and is_instance_valid(_folder_edit): _folder_edit.editable = can_host and not busy


func _clear() -> void:
	if is_instance_valid(_graph): _graph_state = _graph.capture_state()
	_graph = null
	for child in get_children():
		remove_child(child)
		child.queue_free()


func _button(parent: Node, text: String, op: String, extra := {}, available := true) -> Button:
	var button := SgLobbyStyle.button(text, func() -> void: _send(op, extra))
	button.set_meta("t_network", true)
	button.set_meta("available", available)
	parent.add_child(button)
	return button


func _send(op: String, extra: Dictionary = {}) -> void:
	if not _online or _busy or _view.is_empty(): return
	var action := {"op": op, "event": _view.id}
	action.merge(extra)
	action_requested.emit(action)


func _option(parent: Node, title: String, items: Array) -> OptionButton:
	parent.add_child(SgLobbyStyle.label(title, 14))
	var option := OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for item in items: option.add_item(item)
	SgLobbyStyle.option(option)
	parent.add_child(option)
	return option


func _build_setup() -> void:
	_clear()
	_setup_built = true
	var header := SgLobbyStyle.column(self, "Host a LAN tournament", false)
	header.add_child(SgLobbyStyle.label("Random-draw knockout · 2–20 entrants · One trusted local host", 17, true))
	header.add_child(SgLobbyStyle.label("Your computer runs all tables. You can join the draw or organise without playing.", 15, true))
	var settings := SgLobbyStyle.column(self, "Tournament setup")
	settings.add_child(SgLobbyStyle.label("TOURNAMENT NAME", 14))
	_name_edit = LineEdit.new()
	_name_edit.text = "Evening tournament"
	_name_edit.max_length = 32
	_name_edit.name = "TournamentName"
	_name_edit.tooltip_text = "Up to 32 letters, numbers, spaces, - or _. This name appears in the LAN Game Browser."
	SgLobbyStyle.field(_name_edit)
	settings.add_child(_name_edit)
	settings.add_child(SgLobbyStyle.label("WELCOME MESSAGE · OPTIONAL · UP TO 280 CHARACTERS", 14))
	_welcome_edit = LineEdit.new()
	_welcome_edit.name = "TournamentWelcomeEdit"
	_welcome_edit.max_length = SgTournament.MAX_WELCOME
	_welcome_edit.placeholder_text = "A short greeting or instructions for your players"
	SgLobbyStyle.field(_welcome_edit)
	settings.add_child(_welcome_edit)
	settings.add_child(SgLobbyStyle.label("Shown to everyone in the Tournament Hall when they connect or join. It stays available there, without interrupting duels.", 14))
	var limits: Array = []
	for count in range(2, SgTournament.MAX_PLAYERS + 1): limits.append("%d players" % count)
	_limit = _option(settings, "ENTRANT LIMIT", limits)
	_limit.select(6)
	_wins = _option(settings, "WINS NEEDED TO ADVANCE", ["1 win · single game", "2 wins · best of three", "3 wins · best of five"])
	_wins.name = "TournamentWins"
	_policy = _option(settings, "DECK POLICY", ["Players bring their own decks", "One fixed deck for everyone", "Players choose from host-approved decks"])
	_policy.name = "TournamentPolicy"
	settings.add_child(SgLobbyStyle.label("Drawn games award no wins. Decks lock when registration closes; no sideboarding. Standard LAN rules: 20 life, mana burn on, unrestricted decks, no ante.", 15))
	_deck_area = VBoxContainer.new()
	_deck_area.add_theme_constant_override("separation", 10)
	settings.add_child(_deck_area)
	_approved_text = SgLobbyStyle.label("No approved decks selected.", 16)
	_deck_area.add_child(_approved_text)
	var clear := SgLobbyStyle.button("Clear approved decks", func() -> void:
		_approved.clear()
		_update_approved())
	_deck_area.add_child(clear)
	_deck_browser(_deck_area, _available_decks(), func(deck: Dictionary) -> void:
		if _policy.selected == 1: _approved.clear()
		for chosen: Dictionary in _approved:
			if SgTournament.same_list(chosen, deck): return
		if _approved.size() >= SgTournament.MAX_DECKS: return
		_approved.append(_clean_deck(deck))
		_update_approved(), "Add approved deck")
	_policy.item_selected.connect(func(_index: int) -> void:
		_approved.clear()
		_update_approved())
	_update_approved()
	settings.add_child(SgLobbyStyle.label("SAVE FOLDER · LOCAL TO THIS HOST", 14))
	var storage := SgLobbyStyle.row(settings)
	_folder_edit = LineEdit.new()
	_folder_edit.name = "TournamentSaveFolder"
	_folder_edit.text = GamePaths.tournaments_folder()
	_folder_edit.tooltip_text = ProjectSettings.globalize_path(GamePaths.tournaments_folder())
	_folder_edit.placeholder_text = GamePaths.DEFAULT_TOURNAMENTS
	SgLobbyStyle.field(_folder_edit)
	storage.add_child(_folder_edit)
	var browse := SgLobbyStyle.button("Browse…", func() -> void: _make_folder_picker().popup_centered())
	browse.name = "TournamentBrowseFolder"
	browse.set_meta("t_host", true)
	storage.add_child(browse)
	var reset := SgLobbyStyle.button("Default", func() -> void:
		_folder_edit.text = GamePaths.DEFAULT_TOURNAMENTS
		_apply_folder(), Vector2(100, 40))
	reset.set_meta("t_host", true)
	storage.add_child(reset)
	_folder_notice = SgLobbyStyle.label("Remembered on this device. Existing saves are not moved. Keep the folder private: checkpoints include decklists and recovery-code hashes.", 14)
	settings.add_child(_folder_notice)
	_folder_edit.text_submitted.connect(func(_value: String) -> void: _apply_folder())
	_folder_edit.focus_exited.connect(func() -> void: _apply_folder())
	_notice = SgLobbyStyle.label("Use the LAN address and port in Host Game. A private invitation is required for every guest.", 15)
	settings.add_child(_notice)
	var create := SgLobbyStyle.button("Open registration", func() -> void:
		var options := {"name": _name_edit.text.strip_edges(), "welcome": _welcome_edit.text.strip_edges(), "limit": _limit.selected + 2,
			"wins": _wins.selected + 1, "policy": ["own", "fixed", "selection"][_policy.selected],
			"decks": [] if _policy.selected == 0 else _approved.duplicate(true)}
		if not SgTournament.valid_config(options):
			_notice.text = "Use 1–32 letters, numbers, spaces, - or _ for the name. Choose valid decks and a welcome message of at most 280 characters."
			return
		if not _apply_folder(): return
		host_requested.emit(options, ""))
	create.name = "TournamentOpenRegistration"
	create.set_meta("t_host", true)
	settings.add_child(create)
	var recovery := SgLobbyStyle.column(self, "Resume a saved tournament", false)
	recovery.add_child(SgLobbyStyle.label("Completed scores are kept. Interrupted games restart from opening hands. Players need their private recovery codes and your new invitation.", 15, true))
	_saved_events = VBoxContainer.new()
	_saved_events.add_theme_constant_override("separation", 10)
	recovery.add_child(_saved_events)
	_listed_folder = ""
	_refresh_saved()


func _apply_folder() -> bool:
	if not _view.is_empty() or not _can_host or _busy or not is_instance_valid(_folder_edit): return false
	var error := GamePaths.set_tournaments_folder(_folder_edit.text)
	if not error.is_empty():
		_folder_notice.text = error
		return false
	_folder_edit.text = GamePaths.tournaments_folder()
	_folder_edit.tooltip_text = ProjectSettings.globalize_path(GamePaths.tournaments_folder())
	_folder_notice.text = "Remembered on this device. Existing saves are not moved. Keep the folder private: checkpoints include decklists and recovery-code hashes."
	_refresh_saved()
	return true


func _make_folder_picker() -> FileDialog:
	var picker := FileDialog.new()
	picker.name = "TournamentFolderPicker"
	picker.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	picker.access = FileDialog.ACCESS_FILESYSTEM
	picker.title = "Choose the tournament save folder"
	picker.use_native_dialog = true
	picker.size = Vector2i(760, 520)
	var folder := ProjectSettings.globalize_path(GamePaths.tournaments_folder())
	picker.current_dir = folder if DirAccess.dir_exists_absolute(folder) else OS.get_user_data_dir()
	picker.dir_selected.connect(func(path: String) -> void:
		if is_instance_valid(_folder_edit) and _view.is_empty():
			_folder_edit.text = path
			_apply_folder()
		picker.queue_free())
	picker.canceled.connect(picker.queue_free)
	add_child(picker)
	return picker


func _refresh_saved() -> void:
	var folder := GamePaths.tournaments_folder()
	if not is_instance_valid(_saved_events) or _listed_folder == folder: return
	_listed_folder = folder
	for child in _saved_events.get_children():
		_saved_events.remove_child(child)
		child.queue_free()
	var saved := SgTournamentStore.available(folder)
	if saved.is_empty(): _saved_events.add_child(SgLobbyStyle.label("No compatible saved tournaments in the selected folder.", 15, true))
	for entry: Dictionary in saved:
		var button := SgLobbyStyle.button("Resume %s · round %d" % [entry.name, int(entry.round)], func() -> void:
			if _apply_folder() and GamePaths.tournaments_folder() == folder: host_requested.emit({}, entry.path))
		button.tooltip_text = "Saved locally · " + String(entry.phase)
		button.set_meta("t_host", true)
		button.disabled = not _can_host or _busy
		_saved_events.add_child(button)


func _update_approved() -> void:
	_deck_area.visible = _policy.selected != 0
	var names := PackedStringArray()
	for deck: Dictionary in _approved: names.append(deck.name)
	_approved_text.text = "Approved decks (%d/%d):\n%s" % [_approved.size(), 1 if _policy.selected == 1 else SgTournament.MAX_DECKS,
		"None selected" if names.is_empty() else "\n".join(names)]


func _available_decks() -> Array:
	if _catalog.is_empty(): _catalog = SgDeckCatalog.available()
	return _catalog


static func _clean_deck(deck: Dictionary) -> Dictionary:
	return {"name": deck.name, "cards": deck.cards.duplicate(), "sideboard": deck.sideboard.duplicate()}


func _deck_browser(parent: Node, decks: Array, choose: Callable, caption: String) -> void:
	var search := LineEdit.new()
	search.placeholder_text = "Search decks, then review the complete list"
	search.text = _picker_query
	search.name = "TournamentDeckSearch"
	SgLobbyStyle.field(search)
	parent.add_child(search)
	var split := SgLobbyStyle.row(parent)
	split.custom_minimum_size.y = 230
	var list := ItemList.new()
	list.name = "TournamentDeckList"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.custom_minimum_size.x = 220
	SgLobbyStyle.deck_list(list)
	split.add_child(list)
	var detail := RichTextLabel.new()
	detail.name = "TournamentDeckContents"
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.custom_minimum_size.x = 220
	SgLobbyStyle.rich_text(detail)
	split.add_child(detail)
	var use := SgLobbyStyle.button(caption, func() -> void:
		var selected := list.get_selected_items()
		if not selected.is_empty(): choose.call(decks[int(list.get_item_metadata(selected[0]))]))
	use.disabled = true
	parent.add_child(use)
	if not _view.is_empty():
		use.set_meta("t_network", true)
		use.set_meta("available", false)
	list.item_selected.connect(func(index: int) -> void:
		var deck: Dictionary = decks[int(list.get_item_metadata(index))]
		_picker_selected = _clean_deck(deck)
		detail.text = SgLobby._deck_text(deck)
		use.set_meta("available", true)
		use.disabled = not _view.is_empty() and (not _online or _busy))
	var refill := func(query: String) -> void:
		_picker_query = query
		list.clear()
		use.disabled = true
		use.set_meta("available", false)
		detail.text = "Select a deck to review its cards."
		for i in decks.size():
			if not query.is_empty() and not String(decks[i].name).to_lower().contains(query.to_lower()): continue
			list.add_item("%s (%d)" % [decks[i].name, decks[i].cards.size()])
			list.set_item_metadata(list.item_count - 1, i)
			list.set_item_tooltip(list.item_count - 1, decks[i].name)
	search.text_changed.connect(refill)
	refill.call(_picker_query)
	for i in list.item_count:
		if _clean_deck(decks[int(list.get_item_metadata(i))]) == _picker_selected:
			list.select(i)
			list.item_selected.emit(i)
			break


func _name_of(pid: int) -> String:
	if pid == 0: return "Bye"
	for player: Dictionary in _view.entrants:
		if player.id == pid: return player.name
	return "Unavailable entrant"


func _own() -> Dictionary:
	for player: Dictionary in _view.entrants:
		if player.id == _view.you: return player
	return {}


func _current_pair() -> Dictionary:
	if _view.rounds.is_empty(): return {}
	for pair: Dictionary in _view.rounds.back():
		if pair.players.has(_view.you): return pair
	return {}


func _build_hall() -> void:
	var header := SgLobbyStyle.column(self, "Master Panel" if _view.organiser else "Tournament Hall", false)
	header.add_child(SgLobbyStyle.label(_view.config.name, 28, true))
	var welcome: String = _view.config.get("welcome", "")
	if not welcome.is_empty():
		header.add_child(SgLobbyStyle.label("MESSAGE FROM THE ORGANISER", 13, true))
		var message := SgLobbyStyle.label(welcome, 17, true)
		message.name = "TournamentWelcome"
		header.add_child(message)
	var ready := 0
	for player: Dictionary in _view.entrants:
		if player.ready: ready += 1
	var phase_label: String = {"registration": "Registration open", "running": "Round %d" % _view.rounds.size(),
		"complete": "Tournament complete", "cancelled": "Tournament cancelled"}[_view.phase]
	header.add_child(SgLobbyStyle.label("%s  ·  %d / %d entrants  ·  First to %d win(s)" % [phase_label,
		_view.entrants.size(), int(_view.config.limit), int(_view.config.wins)], 18, true))
	header.add_child(SgLobbyStyle.label({"own": "Players bring their own decks", "fixed": "One fixed deck for everyone",
		"selection": "Host-approved deck selection"}[_view.config.policy] + "  ·  No ante or ranking points", 15, true))
	var bot_count := 0
	var unfair_count := 0
	for player: Dictionary in _view.entrants:
		if player.has("bot"):
			bot_count += 1
			if player.bot.unfair: unfair_count += 1
	if bot_count > 0:
		header.add_child(SgLobbyStyle.label("%d computer entrant(s) · %s" % [bot_count,
			"Fair information" if unfair_count == 0 else "%d Unfair challenge bot(s) — they see their opponent's current hand" % unfair_count], 15, true))
	if _view.phase == "complete":
		header.add_child(SgLobbyStyle.label("Champion · " + _name_of(int(_view.champion)) if _view.champion != 0 else "No champion — no entrants remain.", 26, true))
	if not _view.save_error.is_empty():
		var warning := SgLobbyStyle.column(self, "Tournament paused")
		warning.add_child(SgLobbyStyle.label(_view.save_error, 18))
	var tabs := SgLobbyStyle.row(self)
	for entry in [["overview", "Overview"], ["advancement", "Advancement"], ["standings", "Standings"], ["players", "Players"], ["entry", "My entry"]]:
		var button := SgLobbyStyle.button(entry[1], func() -> void: _choose_section(entry[0]), Vector2(108, 36))
		button.name = "TournamentTab_" + entry[0]
		button.toggle_mode = true
		button.set_pressed_no_signal(_section == entry[0])
		button.add_theme_font_size_override("font_size", 16)
		tabs.add_child(button)
	match _section:
		"overview":
			if _view.organiser: _master_controls(ready)
			_build_rounds()
		"advancement": _build_advancement()
		"standings": _build_standings()
		"players": _build_roster()
		"entry": _player_controls()
	var note := SgLobbyStyle.column(self, "Around the table", false)
	note.add_child(SgLobbyStyle.label("The host stays open, even after elimination. A lost connection suspends that table; it does not automatically eliminate an entrant. The organiser can withdraw an absent player.", 15, true))
	note.add_child(SgLobbyStyle.label("The Master Panel shows scores, life totals and turns — never private hands or library order. Play with a host you trust.", 15, true))


func _choose_section(value: String) -> void:
	_section = value
	_snapshot = {"section": value}
	present(_view, _online, _busy, _can_host)


func _build_advancement() -> void:
	var body := SgLobbyStyle.column(self, "Advancement", false)
	body.add_child(SgLobbyStyle.label("Arrows follow actual winners into the next published draw. Pairings are random each round; future pairings are never guessed. Select a player to follow their path, or choose Whole draw for an overview.", 15, true))
	if _view.rounds.is_empty():
		body.add_child(SgLobbyStyle.label("The diagram appears when registration closes.", 18, true))
		return
	_graph = SgTournamentBracket.new()
	body.add_child(_graph)
	_graph.present(_view, _graph_state)


func _build_standings() -> void:
	var title := "Final standings" if _view.phase == "complete" and _view.champion != 0 else "Results so far"
	if _view.phase == "cancelled": title = "Results at cancellation"
	var body := SgLobbyStyle.column(self, title, false)
	body.add_child(SgLobbyStyle.label("Shared places mean elimination in the same round; there is no third-place match. Series count played results only. Byes and forfeits are separate. No global ranking points.", 15, true))
	var rows := SgTournamentResults.standings(_view)
	var table := Tree.new()
	table.name = "TournamentStandings"
	table.columns = 7
	table.hide_root = true
	table.column_titles_visible = true
	table.select_mode = Tree.SELECT_ROW
	table.custom_minimum_size.y = 360
	table.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var columns := [["Place", 46], ["Player", 170], ["Series W–L", 82], ["Games W–L–D", 108], ["Byes", 42], ["Forfeit W–L", 91], ["Status", 130]]
	for index in columns.size():
		table.set_column_title(index, columns[index][0])
		table.set_column_custom_minimum_width(index, columns[index][1])
		table.set_column_expand(index, index == 1)
		table.set_column_clip_content(index, true)
	var paper := StyleBoxFlat.new()
	paper.bg_color = SgLobbyStyle.PAPER
	paper.set_content_margin_all(8)
	table.add_theme_stylebox_override("panel", paper)
	table.add_theme_color_override("font_color", UiChrome.INK)
	table.add_theme_color_override("font_selected_color", SgLobbyStyle.PALE)
	table.add_theme_color_override("title_button_color", UiChrome.INK)
	var heading := StyleBoxFlat.new()
	heading.bg_color = SgLobbyStyle.WELL
	heading.border_color = SgLobbyStyle.GOLD
	heading.border_width_bottom = 2
	heading.set_content_margin_all(8)
	for state in ["title_button_normal", "title_button_hover", "title_button_pressed"]:
		table.add_theme_stylebox_override(state, heading)
	table.add_theme_font_size_override("font_size", 16)
	table.add_theme_font_size_override("title_button_font_size", 14)
	table.add_theme_constant_override("v_separation", 10)
	var font := GameSkin.font("font_body")
	if font != null:
		table.add_theme_font_override("font", font)
		table.add_theme_font_override("title_button_font", font)
	body.add_child(table)
	var root := table.create_item()
	for row: Dictionary in rows:
		var item := table.create_item(root)
		item.set_metadata(0, row.id)
		var cells := ["—" if row.place == 0 else ("=%d" if row.tied else "%d") % int(row.place), row.name,
			"%d–%d" % [row.series_won, row.series_lost], "%d–%d–%d" % [row.games_won, row.games_lost, row.draws],
			str(row.byes), "%d–%d" % [row.forfeits_won, row.forfeits_lost], row.status]
		for index in cells.size():
			item.set_text(index, cells[index])
			item.set_tooltip_text(index, "%s\nDeck: %s\n%s" % [row.name, row.deck_name, row.status])
			if row.place == 1: item.set_custom_color(index, Color8(39, 92, 47))
		if row.id == _selected_entrant: item.select(0)
	table.item_selected.connect(func() -> void:
		var item := table.get_selected()
		if item != null: _selected_entrant = int(item.get_metadata(0)))
	var follow := SgLobbyStyle.button("Follow selected player", func() -> void:
		if _selected_entrant == 0: return
		_graph_state["player"] = _selected_entrant
		_graph_state["follow"] = true
		_choose_section("advancement"))
	body.add_child(follow)
	body.add_child(SgLobbyStyle.label("Select a row to see the full player and deck name in its tooltip. The diagram traces their published matches.", 14, true))


func _master_controls(ready: int) -> void:
	var controls := SgLobbyStyle.column(self, "Organiser controls")
	if _view.phase == "registration":
		controls.add_child(SgLobbyStyle.label("%d entrant(s) ready. Starting locks the roster and decks, then publishes the first random draw." % ready, 16))
		_button(controls, "Start tournament", "t_start", {}, _view.entrants.size() >= 2 and ready == _view.entrants.size())
		var remaining: int = int(_view.config.limit) - _view.entrants.size()
		if remaining > 0:
			var setup := SgBotSetup.new()
			controls.add_child(setup)
			setup.changed.connect(func(value: Dictionary) -> void: _bot_draft = value)
			setup.submitted.connect(func(count: int, options: Dictionary, deck: Dictionary) -> void:
				_send("t_bots", {"count": count, "bot": options, "deck": deck}))
			setup.build(remaining, _available_decks() if _view.config.policy == "own" else _view.config.decks as Array, _bot_draft)
			setup.find_child("AddBots", true, false).set_meta("t_network", true)
		controls.add_child(SgLobbyStyle.label("Add bots in batches to mix levels and decks. They count toward the entrant limit and ready themselves for each game. Remove an entry in Players before starting.", 14))
	elif _view.phase == "running":
		var finished := true
		for pair: Dictionary in _view.rounds.back():
			if pair.status not in ["finished", "bye"]: finished = false
		controls.add_child(SgLobbyStyle.label("Human players confirm each new game in the hall; bots ready automatically. Draw the next round when all pairings finish and players have returned.", 16))
		_button(controls, "Draw next round", "t_next", {}, finished and _view.tables.is_empty())
	if not _view.tables.is_empty():
		_confirm_button(controls, "Return finished tables to hall", "t_clear", {}, "Move players from finished games back to the hall?")
	if not _view.save_error.is_empty(): _button(controls, "Retry save", "t_retry")
	if _view.phase in ["registration", "running"]:
		_confirm_button(controls, "Cancel tournament", "t_cancel", {}, "Cancel this tournament and close all its tables?")
	else:
		_button(controls, "Finish hosting this tournament", "t_close", {}, _view.tables.is_empty())
	controls.add_child(SgLobbyStyle.label("Progress is saved on this host. There is no automatic host migration or public ranking.", 14))


func _confirm_button(parent: Node, caption: String, op: String, extra: Dictionary, explanation: String) -> void:
	var key := op + str(extra)
	var button := SgLobbyStyle.button("Confirm: " + caption if _confirm == key else caption, func() -> void:
		if _confirm == key:
			_confirm = ""
			_send(op, extra)
		else:
			_confirm = key
			_snapshot = {"confirm": key}
			present(_view, _online, _busy, _can_host))
	button.tooltip_text = explanation + " Click again to confirm."
	button.set_meta("t_network", true)
	parent.add_child(button)
	if _confirm == key: parent.add_child(SgLobbyStyle.label(explanation + " Click Confirm to continue.", 15))


func _player_controls() -> void:
	var own := _own()
	var body := SgLobbyStyle.column(self, "Your entry")
	if own.is_empty():
		body.add_child(SgLobbyStyle.label("The organiser may enter the tournament or stay outside the draw.", 16))
		if _view.phase == "registration": _button(body, "Join tournament", "t_join", {}, _view.entrants.size() < _view.config.limit)
		var recovery := LineEdit.new()
		recovery.name = "TournamentRecoveryCode"
		recovery.placeholder_text = "Private recovery code for an existing entry"
		recovery.max_length = 64
		recovery.secret = true
		recovery.text = _recovery_draft
		recovery.text_changed.connect(func(value: String) -> void: _recovery_draft = value)
		SgLobbyStyle.field(recovery)
		body.add_child(recovery)
		var recover := SgLobbyStyle.button("Recover my entry", func() -> void:
			_send("t_recover", {"code": recovery.text.strip_edges()}))
		recover.set_meta("t_network", true)
		body.add_child(recover)
		return
	body.add_child(SgLobbyStyle.label("%s\nDeck: %s" % [own.name, own.deck_name], 19))
	if not _view.code.is_empty():
		body.add_child(SgLobbyStyle.button("Copy private recovery code", func() -> void:
			DisplayServer.clipboard_set(_view.code)))
		body.add_child(SgLobbyStyle.label("Save this code privately before play. It reclaims your entry after a restart. Clipboard history may retain it; never share it with other players.", 14))
	if _view.phase == "registration":
		if _view.config.policy != "fixed":
			var decks := _available_decks() if _view.config.policy == "own" else _view.config.decks as Array
			_deck_browser(body, decks, func(deck: Dictionary) -> void:
				var action := _clean_deck(deck)
				action.op = "t_deck"
				action.event = _view.id
				action_requested.emit(action), "Register this deck")
		_button(body, "Not ready" if own.ready else "Ready for tournament", "t_ready", {"value": not own.ready}, not _view.deck.is_empty())
	elif _view.phase == "running" and not own.withdrawn:
		var pair := _current_pair()
		if not pair.is_empty() and pair.status == "waiting":
			_button(body, "Not ready" if own.ready else "Ready for next game", "t_ready", {"value": not own.ready})
		else: body.add_child(SgLobbyStyle.label("Follow your table in Overview, your path in Advancement and your results in Standings.", 16))
	if not _view.deck.is_empty():
		body.add_child(SgLobbyStyle.button("Hide registered deck" if _reviewing else "Review registered deck", func() -> void:
			_reviewing = not _reviewing
			_snapshot = {"review": _reviewing}
			present(_view, _online, _busy, _can_host)))
		if _reviewing:
			var details := RichTextLabel.new()
			details.custom_minimum_size.y = 230
			SgLobbyStyle.rich_text(details)
			details.text = SgLobby._deck_text(_view.deck)
			body.add_child(details)
	if SgTournamentResults.active(_view, int(own.id)):
		_confirm_button(body, "Withdraw my entry", "t_withdraw", {}, "Withdraw from the tournament? An unfinished pairing is forfeited.")


func _build_roster() -> void:
	var roster := SgLobbyStyle.column(self, "Entrants")
	if _view.entrants.is_empty(): roster.add_child(SgLobbyStyle.label("Waiting for players to register.", 18))
	for player: Dictionary in _view.entrants:
		var row := SgLobbyStyle.row(roster)
		var status := "Registered"
		for result: Dictionary in SgTournamentResults.standings(_view):
			if result.id == int(player.id): status = result.status
		if not player.connected: status += " · Disconnected"
		elif player.ready: status += " · Ready"
		if player.has("bot"):
			status += " · " + SgBotPlayer.label(player.bot) + (" — sees opponent's hand" if player.bot.unfair else " — fair information")
		var label := SgLobbyStyle.label("%s  ·  %s\n%s" % [player.name, status, player.deck_name], 17)
		label.add_theme_color_override("font_color", UiChrome.ACCENT if not player.connected or player.withdrawn else UiChrome.INK)
		row.add_child(label)
		if _view.organiser and SgTournamentResults.active(_view, int(player.id)):
			_confirm_button(row, "Withdraw", "t_remove", {"player": player.id}, "Withdraw %s?" % player.name)


func _build_rounds() -> void:
	if _view.rounds.is_empty():
		var waiting := SgLobbyStyle.column(self, "The draw", false)
		waiting.add_child(SgLobbyStyle.label("Pairings appear when the organiser closes registration. Any first-round byes are drawn at random.", 17, true))
	for r in range(maxi(0, _view.rounds.size() - 1), _view.rounds.size()):
		var round_box := SgLobbyStyle.column(self, "Round %d" % (r + 1), false)
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 12)
		round_box.add_child(grid)
		var byes := PackedStringArray()
		for pair: Dictionary in _view.rounds[r]:
			if pair.status == "bye":
				var name_value := _name_of(int(pair.winner))
				for player: Dictionary in _view.entrants:
					if player.id == pair.winner and player.get("withdrawn", false): name_value += " (withdrawn)"
				byes.append(name_value)
				continue
			var card := VBoxContainer.new()
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			card.add_theme_constant_override("separation", 8)
			var tile := SgLobbyStyle.panel(card)
			tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			grid.add_child(tile)
			card.add_child(SgLobbyStyle.label("TABLE %d" % SgTournament.table_number(pair.id), 13))
			for seat in 2:
				if pair.players[seat] == 0: continue
				var line := SgLobbyStyle.row(card)
				line.add_child(SgLobbyStyle.label(_name_of(int(pair.players[seat])), 18))
				var score := SgLobbyStyle.label(str(pair.wins[seat]), 28)
				score.autowrap_mode = TextServer.AUTOWRAP_OFF
				score.custom_minimum_size.x = 32
				score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				score.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				score.size_flags_horizontal = Control.SIZE_SHRINK_END
				score.add_theme_color_override("font_color", Color8(46, 99, 53) if pair.winner == pair.players[seat] else UiChrome.INK)
				line.add_child(score)
			var summary := "Waiting for both players to be ready" if pair.status == "waiting" else "Game %d in progress" % int(pair.game)
			if pair.status == "bye": summary = "Bye · advances without playing"
			elif pair.status == "finished": summary = "%s · %s" % [pair.reason, _name_of(int(pair.winner)) if pair.winner != 0 else "No advancing player"]
			elif _view.phase == "cancelled": summary = "Cancelled · no further games"
			card.add_child(SgLobbyStyle.label(summary, 15))
			if pair.draws > 0: card.add_child(SgLobbyStyle.label("%d drawn game(s) · no wins awarded" % int(pair.draws), 14))
			for table: Dictionary in _view.tables:
				if table.pair == pair.id:
					card.add_child(SgLobbyStyle.label("Life %d : %d  ·  Turn %d\n%s" % [int(table.life[0]), int(table.life[1]), int(table.turn), String(table.step).capitalize()], 15))
		if not byes.is_empty():
			round_box.add_child(SgLobbyStyle.label("Byes · no game played\n" + ", ".join(byes), 15, true))
