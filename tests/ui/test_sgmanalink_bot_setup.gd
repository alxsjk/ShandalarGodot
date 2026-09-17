extends GutTest
## The shared bot chooser and the real online duel's challenge disclosure.


func _decks() -> Array:
	return [{"name": "White Knights", "cards": Array(StarterDecks.WHITE_KNIGHTS), "sideboard": []}]


func test_bot_setup_restores_the_fair_level_and_publishes_explicit_options() -> void:
	var setup := SgBotSetup.new()
	add_child_autofree(setup)
	setup.build(8, _decks())
	assert_eq(setup._level.item_count, 4)
	assert_eq(setup._level.get_item_text(3), "Wizard")
	assert_false(setup._unfair.button_pressed)
	assert_eq(setup._unfair.get_theme_color("font_color"), UiChrome.INK)
	assert_true(setup._unfair.has_theme_icon_override("checked"))
	setup._level.select(0)
	setup._level.item_selected.emit(0)
	setup._unfair.button_pressed = true
	assert_true(setup._level.disabled)
	assert_eq(setup._level.selected, 3)
	assert_true(setup.draft.bot.unfair)
	setup._unfair.button_pressed = false
	assert_false(setup._level.disabled)
	assert_eq(setup._level.selected, 0)
	setup._count.value = 6
	assert_eq(setup.draft.count, 6)
	assert_true(SgBotPlayer.valid(setup.draft.bot))
	var events: Array = []
	setup.submitted.connect(func(count: int, options: Dictionary, deck: Dictionary) -> void:
		events.append([count, options, deck]))
	setup.find_child("AddBots", true, false).pressed.emit()
	assert_eq(events.size(), 1)
	assert_eq(events[0][0], 6)
	assert_eq(events[0][1].level, 0)
	assert_eq(events[0][2].name, "White Knights")
	var reopened := SgBotSetup.new()
	add_child_autofree(reopened)
	reopened.build(3, _decks(), setup.draft)
	assert_eq(reopened._level.selected, 0)
	assert_eq(int(reopened._count.value), 3, "count clamps when another entrant takes a seat")


func test_bot_controls_and_deck_review_fit_inside_the_small_tournament_window() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 600)
	add_child_autofree(viewport)
	var lobby := SgLobby.new()
	viewport.add_child(lobby)
	lobby._show_page("tournament")
	var event := SgTournament.new()
	assert_eq(event.configure({"name": "Wizard Cup", "limit": 20, "wins": 1, "policy": "fixed", "decks": _decks()}, 4250), "")
	var view := {"id": event.id, "config": event.config, "phase": event.phase, "revision": 1, "champion": 0,
		"entrants": [], "rounds": [], "you": 0, "deck": {}, "code": "", "organiser": true, "save_error": "", "paused": false, "tables": []}
	assert_true(SgTournamentProtocol.view(view))
	lobby._tournament_panel.present(view, true, false, true)
	for i in 8: await get_tree().process_frame
	var list := lobby._tournament_panel.find_child("BotDeckList", true, false) as ItemList
	assert_not_null(list)
	assert_lte(list.get_global_rect().end.x, 940.0)
	assert_gte(list.get_global_rect().position.x, 20.0)
	assert_lte(lobby._window.size.x, 920.0)
	assert_true(lobby._tournament_panel.find_child("AddBots", true, false).has_meta("t_network"))
	lobby._tournament_panel.present(view, false, false, true)
	assert_true(lobby._tournament_panel.find_child("AddBots", true, false).disabled)


func test_online_unfair_badge_uses_public_bot_metadata_without_a_client_agent() -> void:
	var referee := SgPracticeMatch.new(4250)
	var options := SgBotPlayer.defaults()
	options.unfair = true
	assert_true(referee.set_bot(1, options))
	var room := {"id": "r1", "name": "Unfair challenge", "seat": 0, "names": ["Player", "Unfair bot"],
		"revision": 1, "ready": [true, true], "connected": [true, true], "game": referee.view(0),
		"deck_names": ["Forest practice", "Forest practice"], "deck": {}, "bots": [{}, options]}
	assert_true(SgViewProtocol.room(room))
	var screen := SgDuelView.new()
	add_child_autofree(screen)
	screen.present(room, true, false)
	assert_true(screen.config.unfair[1])
	assert_true(screen.config.is_ai(1))
	assert_true(screen._ais.is_empty(), "client never schedules a computer player")
	assert_eq(screen.hidden_hands, [1], "challenge does not reveal the bot's hand")
	assert_not_null(screen.find_child("UnfairNotice", true, false))
