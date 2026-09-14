extends GameTest
## Parity is structural: the real DuelScreen drives a detached projection.

var referee: SgPracticeMatch
var revision := 1
var commands: Array = []
var refusals: Array = []


func before_each() -> void:
	super.before_each()
	referee = SgPracticeMatch.new(42)
	referee.game = g
	revision = 1
	commands.clear()
	refusals.clear()
	g.interactive_choices = true
	g.set_agent(0, HumanAgent.new())
	g.set_agent(1, HumanAgent.new())


func _room(seat := 0) -> Dictionary:
	return {"id": "r1", "name": "Friendly duel", "seat": seat,
		"names": ["Azure Fox", "Amber Owl"], "revision": revision,
		"ready": [true, true], "connected": [true, true], "game": referee.view(seat),
		"deck_names": referee.deck_names.duplicate(), "deck": {}}


func _screen(seat := 0) -> SgDuelView:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 600)
	add_child_autofree(viewport)
	var screen := SgDuelView.new()
	screen.stops.from_masks(PackedInt32Array([255, 255, 255, 255]))
	viewport.add_child(screen)
	screen.action_requested.connect(_act.bind(screen, seat))
	screen.present(_room(seat), true, false)
	return screen


func _act(action: Dictionary, screen: SgDuelView, seat: int) -> void:
	commands.append(action.duplicate(true))
	var error := referee.act(seat, action)
	if not error.is_empty():
		refusals.append(error)
		screen.show_notice(error)
	else: revision += 1
	screen.present.call_deferred(_room(seat), true, false)


func _pump() -> void:
	for i in 8: await get_tree().process_frame


func _local(screen: SgDuelView, card: CardInstance) -> CardInstance:
	return screen.game.find_instance(screen.projection.local_id(referee._handle(int(screen._room.seat), card)))


func test_online_is_the_actual_duel_screen_with_private_projection() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var own := give_hand(1, "Craw Wurm")
	give_hand(0, "Durkwood Boars")
	put_battlefield(0, "Giant Spider")
	var bear := put_battlefield(1, "Grizzly Bears")
	var screen := _screen(1)
	await _pump()
	assert_true(screen is DuelScreen)
	assert_true(screen.game is SgDuelProjection)
	assert_ne(screen.game, g)
	assert_eq(screen.game.players[0].hand[0].data.card_name, own.data.card_name)
	assert_eq(screen.game.players[1].hand[0].data.card_name, "Unknown card")
	assert_eq(screen.game.players[0].battlefield[0], _local(screen, bear))
	assert_ne(_local(screen, own), own)
	assert_eq(_local(screen, own).owner_id, 0)
	assert_eq(screen._field_rows.size(), 2)
	assert_not_null(screen._card_preview)
	assert_not_null(screen._flight)
	assert_not_null(screen._audio)
	assert_eq(screen._ais.size(), 0, "a remote human is never an AI agent")
	for node in screen.find_children("*", "Button", true, false):
		if node is MiniCard:
			assert_ne(node.instance.data.card_name, "Durkwood Boars")
	for card in screen.game.players[1].library: assert_eq(card.data.card_name, "Unknown card")


func test_click_target_then_tap_mana_preserves_the_spell_and_casts_once() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var bolt := give_hand(0, "Lightning Bolt")
	var mountain := put_battlefield(0, "Mountain")
	var bear := put_battlefield(1, "Grizzly Bears")
	var screen := _screen()
	screen._on_card_clicked(_local(screen, bolt))
	await _pump()
	assert_eq(screen.mode, DuelScreen.Mode.TARGETING)
	assert_null(screen._x_dialog)
	screen._on_card_clicked(_local(screen, bear))
	await _pump()
	assert_eq(screen.mode, DuelScreen.Mode.PAYING)
	assert_eq(screen._pending_card, _local(screen, bolt))
	screen._on_card_clicked(_local(screen, mountain))
	await _pump()
	assert_eq(g.stack.size(), 1)
	assert_eq(g.stack[0].card, bolt)
	assert_eq(screen.mode, DuelScreen.Mode.NORMAL)
	assert_null(screen._pending_card)
	assert_eq(screen.game.stack[0].card, _local(screen, bolt))
	assert_string_contains(screen.game.stack[0].description, "Grizzly Bears")
	assert_true(mountain.tapped)
	assert_eq(commands.filter(func(a: Dictionary) -> bool: return a.op == "submit").size(), 2, "one unpaid attempt, one paid cast")
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)


func test_double_click_autopays_without_replacing_target_selection() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var bolt := give_hand(0, "Lightning Bolt")
	var mountain := put_battlefield(0, "Mountain")
	var bear := put_battlefield(1, "Grizzly Bears")
	var screen := _screen()
	var card := _local(screen, bolt)
	screen._on_card_clicked(card)
	screen._auto_cast(card)
	await _pump()
	assert_eq(screen.mode, DuelScreen.Mode.TARGETING)
	assert_true(mountain.tapped)
	screen._on_card_clicked(_local(screen, bear))
	await _pump()
	assert_eq(g.stack.size(), 1)
	assert_eq(refusals, [])


func test_shared_combat_window_and_click_damage_assignment() -> void:
	g.rules.free_damage_assignment = true
	var wurm := put_battlefield(0, "Craw Wurm")
	var first := put_battlefield(1, "Grizzly Bears")
	var second := put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	var screen := _screen()
	screen._on_card_clicked(_local(screen, wurm))
	assert_eq(screen._selected_attackers, [_local(screen, wurm).id])
	assert_not_null(screen._combat_window)
	screen._on_done()
	await _pump()
	for i in 8:
		if g.awaiting_blockers: break
		assert_ok(g.pass_priority(g.priority_player))
	var opponent := _screen(1)
	for bear in [first, second]:
		opponent._on_card_clicked(_local(opponent, bear))
		opponent._on_card_clicked(_local(opponent, wurm))
	assert_eq(opponent._block_map.size(), 2)
	opponent._on_done()
	await _pump()
	for i in 8:
		if g.awaiting_damage_assignment: break
		assert_ok(g.pass_priority(g.priority_player))
	assert_true(g.awaiting_damage_assignment, str(Mtg.Step.keys()[g.current_step()]))
	assert_true(SgViewProtocol.room(_room()), str(_room().game.presentation))
	revision += 1
	screen.present(_room(), true, false)
	assert_eq(screen.mode, DuelScreen.Mode.DAMAGE)
	for i in 3: screen._on_card_clicked(_local(screen, first))
	assert_eq(screen._pending_damage_for(_local(screen, first).id), 3)
	for i in 3: screen._on_card_clicked(_local(screen, second))
	await _pump()
	assert_eq(first.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(second.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(refusals, [])


func test_shared_choice_dialog_and_authorized_library_search() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var tutor := give_hand(0, "Demonic Tutor")
	add_mana(0, Mtg.ManaColor.B, 2)
	var screen := _screen()
	screen._on_card_clicked(_local(screen, tutor))
	await _pump()
	assert_eq(g.stack.size(), 1)
	assert_null(screen._search_dialog, "no speculative peek before resolution")
	for i in 4:
		if g.awaiting_choice != null: break
		assert_ok(g.pass_priority(g.priority_player))
	revision += 1
	screen.present(_room(), true, false)
	assert_not_null(screen._choice_overlay)
	assert_eq(screen.game.awaiting_choice.source, "Demonic Tutor")
	screen._on_choice_option(0)
	await _pump()
	assert_null(g.awaiting_choice)
	assert_eq(g.players[0].hand.back().data.card_name, "Forest")
	assert_eq(refusals, [])


func test_pending_action_is_not_repeated_by_refresh_or_disconnection() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var land := give_hand(0, "Forest")
	var screen := _screen()
	screen.action_requested.disconnect(_act.bind(screen, 0))
	watch_signals(screen)
	screen._on_card_clicked(_local(screen, land))
	screen._on_card_clicked(_local(screen, land))
	screen._on_done()
	assert_signal_emit_count(screen, "action_requested", 1)
	screen.present(_room(), false, false)
	screen._on_card_clicked(_local(screen, land))
	assert_signal_emit_count(screen, "action_requested", 1)
	assert_true(screen._pass_button.disabled)
	assert_false(g.players[0].battlefield.has(land))


func test_x_modal_and_live_ability_use_shared_controls() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var ball := give_hand(0, "Fireball")
	for i in 5: put_battlefield(0, "Mountain")
	var screen := _screen()
	screen._on_card_clicked(_local(screen, ball))
	assert_not_null(screen._x_dialog)
	assert_gte(screen._x_spin.max_value, 4.0)
	screen._x_spin.value = 3
	screen._on_x_confirmed()
	await _pump()
	screen._auto_tap_for_pending()
	await _pump()
	for i in 3: screen._on_life_clicked(1)
	await _pump()
	assert_eq(g.stack.size(), 1)
	assert_eq(g.stack[0].x_value, 3)
	resolve_stack()
	assert_eq(g.players[1].life, 17)
	var salve := give_hand(0, "Healing Salve")
	add_mana(0, Mtg.ManaColor.W)
	revision += 1
	screen.present(_room(), true, false)
	screen._on_card_clicked(_local(screen, salve))
	assert_not_null(screen._mode_overlay)
	screen._on_mode_chosen(0)
	await _pump()
	screen._on_life_clicked(0)
	await _pump()
	resolve_stack()
	assert_eq(g.players[0].life, 23)
	var wisp := put_battlefield(0, "Will-o'-the-Wisp")
	add_mana(0, Mtg.ManaColor.B)
	revision += 1
	screen.present(_room(), true, false)
	screen._on_card_clicked(_local(screen, wisp))
	assert_true(screen._ability_menu.visible)
	screen._on_ability_chosen(0)
	await _pump()
	resolve_stack()
	assert_gt(wisp.regeneration_shields, 0)
	assert_eq(refusals, [])


func test_public_moves_keep_flights_but_hidden_moves_retire_identity() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var bear := give_hand(0, "Grizzly Bears")
	add_mana(0, Mtg.ManaColor.G, 2)
	var screen := _screen()
	var before := _local(screen, bear)
	screen._on_card_clicked(before)
	await _pump()
	assert_eq(screen.game.stack[0].card, before)
	resolve_stack()
	revision += 1
	screen.present(_room(), true, false)
	assert_eq(_local(screen, bear), before)
	assert_eq(before.zone, Mtg.Zone.BATTLEFIELD)
	var enemy := put_battlefield(1, "Giant Spider")
	revision += 1
	screen.present(_room(), true, false)
	var old_handle := referee._handle(0, enemy)
	var old_id := screen.projection.local_id(old_handle)
	g.return_to_hand(enemy)
	revision += 1
	screen.present(_room(), true, false)
	assert_null(screen.game.find_instance(old_id))
	assert_false(screen.projection.faces.has(old_handle))
	assert_null(referee._card(0, old_handle))


func test_opening_order_and_network_exit_are_explicit() -> void:
	referee = SgPracticeMatch.new(42)
	var winner := referee.toss_winner
	var screen := _screen(winner)
	assert_not_null(screen._network_opening)
	assert_eq(screen._network_opening.button_labels(), PackedStringArray(["Play first", "Draw first"]))
	screen._opening_answer(1)
	await _pump()
	assert_eq(referee.first_player, 1 - winner)
	assert_true(referee.order_chosen)
	assert_eq(screen._network_opening.button_labels(), PackedStringArray(["Take mulligan", "Start the duel"]))
	screen._run_intro()
	var intro: DuelIntro = screen._intro_overlay
	intro.reconfigure_pressed.emit()
	assert_gt(screen._network_dialog.z_index, intro.z_index)
	assert_true(is_instance_valid(screen._intro_overlay), "leave needs confirmation, not offline navigation")
	watch_signals(screen)
	assert_signal_not_emitted(screen, "exit_requested")
	intro.go_pressed.emit()
	assert_null(screen._intro_overlay)
	for button in screen._network_dialog.find_children("*", "Button", true, false):
		if button.text == "Confirm close": button.pressed.emit()
	assert_signal_emitted(screen, "exit_requested")


func test_sound_events_are_filtered_and_not_replayed_by_refresh() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var screen := _screen()
	var enemy := put_battlefield(1, "Grizzly Bears")
	referee.view(0)
	g.draw_cards(1, 1)
	assert_true(referee.visual_events[0].is_empty(), "private draw identity stays at its seat")
	g.destroy(enemy)
	revision += 1
	screen.present(_room(), true, false)
	var sounds: Array = screen._audio.recent.duplicate()
	screen.present(_room(), true, false)
	assert_eq(screen._audio.recent, sounds)
	assert_true(SgViewProtocol.game(referee.view(0)))
	var broken := referee.view(0)
	broken.presentation.cues.append({"serial": 999, "cue": "../../private"})
	assert_false(SgViewProtocol.game(broken))


func test_unpayable_spell_cancels_instead_of_trapping_the_payment_prompt() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var wurm := give_hand(0, "Craw Wurm")
	var screen := _screen()
	screen._on_card_clicked(_local(screen, wurm))
	await _pump()
	assert_eq(screen.mode, DuelScreen.Mode.NORMAL)
	assert_null(screen._pending_card)
	assert_true(referee.actions.draft.is_empty())
	assert_eq(wurm.zone, Mtg.Zone.HAND)


func test_revealed_hand_and_information_before_a_question_remain_visible() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	give_hand(1, "Lightning Bolt")
	var revelation := put_battlefield(0, "Revelation")
	var screen := _screen()
	assert_false(screen.hidden_hands.has(1))
	g.sacrifice_permanent(revelation)
	revision += 1
	screen.present(_room(), true, false)
	assert_true(screen.hidden_hands.has(1))
	var question := PlayerChoice.new(PlayerChoice.Kind.YES_NO, 0, "Shuffle this library?")
	question.source = "Visions"
	question.information = [{"viewer": 0, "title": "Visions", "cards": ["Forest", "Lightning Bolt"]}]
	g.awaiting_choice = question
	revision += 1
	screen.present(_room(), true, false)
	assert_not_null(screen._choice_overlay)
	var shown := ""
	for label in screen._choice_overlay.find_children("*", "Label", true, false): shown += label.text
	assert_string_contains(shown, "Lightning Bolt")
	assert_true(referee.view(1).choice.is_empty())
