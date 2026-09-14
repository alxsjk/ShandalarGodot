extends GutTest
## Pass-and-play privacy: empty opening battlefields, explicit seat names,
## concealed hands, deliberate reveal/hide and private control handoffs.


var screen: DuelScreen


func before_each() -> void:
	screen = load("res://game/duel/duel_screen.tscn").instantiate()
	screen.config = DuelConfig.hotseat_default()
	screen.config.hotseat_privacy = true
	screen.config.rng_seed = 92000
	add_child_autofree(screen)
	await get_tree().process_frame
	await get_tree().process_frame


func test_hotseat_starts_with_empty_battlefields_and_concealed_hands() -> void:
	for pid in 2:
		assert_true(screen.game.players[pid].battlefield.is_empty(),
			"opening cards are in hand, never already on the battlefield")
		assert_true(screen.hidden_hands.has(pid), "neither opening hand starts exposed")
		assert_true(screen._hand_rows[1 - pid] is StackHand,
			"both players have a real hand stack, not cards spread over the board")
	assert_true(screen._card_preview._back.visible, "no private draw in the Showcase")


func test_hotseat_coin_badge_names_the_player_and_side() -> void:
	for pid in 2:
		var badge := CoinToss.result_badge(screen.config, pid, 0)
		add_child_autofree(badge)
		assert_eq((badge.get_child(badge.get_child_count() - 1) as Label).text,
			DuelConfig.seat_label(pid), "no ambiguous Your seat in hotseat")
		assert_eq(CoinToss.verdict_for(screen.config, pid, true),
			"%s won the coin toss." % DuelConfig.seat_label(pid))


func _stand(pid: int) -> void:
	screen.game.active_player = pid
	screen.game._enter_step(Mtg.STEP_ORDER.find(Mtg.Step.MAIN1))
	screen._refresh()


func test_match_keeps_private_hotseat_for_every_duel() -> void:
	var match_screen := MatchScreen.new()
	match_screen.config = screen.config
	for i in 3:
		assert_true(match_screen._config_for_this_duel().private_hotseat())
	match_screen.free()


func after_each() -> void:
	# Refresh removes old card widgets immediately and frees them at frame end.
	await get_tree().process_frame
	await get_tree().process_frame


func _hand(pid: int) -> HotseatHand:
	return screen._hand_rows[1 - pid] as HotseatHand


func test_hotseat_show_hide_is_private_for_either_seat(pid = use_parameters([0, 1])) -> void:
	_stand(pid)
	var hand := _hand(pid)
	var other := _hand(1 - int(pid))
	assert_true(hand.active)
	assert_false(other.active)
	assert_true(hand.toggle_button.visible)
	assert_false(other.toggle_button.visible)
	assert_eq(hand.toggle_button.text, "Show hand")
	assert_eq(hand.toggle_button.focus_mode, Control.FOCUS_NONE,
		"clicking Show/Hide must not steal Enter or Space from the duel")
	assert_eq(hand._backs.get_child_count(), screen.game.players[pid].hand.size())
	assert_eq(hand._pile.get_child_count(), 0, "hidden hands construct no named card widgets")
	assert_eq(other._backs.get_child_count(), 0, "the inactive seat has only a count")
	for back in hand._backs.get_children():
		assert_true(back is Panel, "anonymous card-back artwork has no card identity")
		assert_eq(back.mouse_filter, Control.MOUSE_FILTER_IGNORE)
		assert_eq(back.tooltip_text, "")
	var inst := screen.game.players[pid].hand[0]
	screen._on_card_clicked(inst)
	assert_eq(inst.zone, Mtg.Zone.HAND, "concealed cards cannot be played")
	hand.toggle_button.pressed.emit()
	assert_true(screen._may_see_hand(pid))
	assert_false(screen._may_see_hand(1 - int(pid)))
	assert_eq(hand.toggle_button.text, "Hide hand")
	assert_gt(hand._pile.get_child_count(), 0)
	var face := CardPile._face_in(hand._pile.get_child(0))
	hand._pile._on_card_hover(face.instance, face)
	assert_false(screen._card_preview._back.visible)
	hand.toggle_button.pressed.emit()
	assert_false(screen._may_see_hand(pid))
	assert_eq(hand.toggle_button.text, "Show hand")
	assert_true(screen._card_preview._back.visible, "hiding clears the enlarged private card")
	hand._pile._on_card_hover(inst, face)
	assert_true(screen._card_preview._back.visible, "a queued old hover cannot reveal it again")
	assert_gt(hand.toggle_button.position.x, hand._frame.size.x,
		"Show/Hide sits to the right of the card stack")


func test_hotseat_priority_handoff_conceals_both_hands_without_flipping_the_board() -> void:
	_stand(0)
	_hand(0).toggle_button.pressed.emit()
	assert_eq(screen.game.pass_priority(0), "")
	assert_eq(screen._hotseat_seat, 1)
	assert_false(screen._hotseat_revealed)
	assert_eq(screen.hidden_hands, [0, 1] as Array[int])
	assert_true(_hand(1).active)
	assert_false(_hand(0).active)
	assert_eq(screen._phase_key()[0], PhaseStops.Half.YOURS,
		"a top-player response is still the bottom player's turn")
	_hand(1).toggle_button.pressed.emit()
	assert_true(screen._may_see_hand(1))
	assert_false(screen._may_see_hand(0))
	_stand(1)
	assert_false(screen._hotseat_revealed, "a new turn conceals even for the same viewer")
	assert_eq(screen._phase_key()[0], PhaseStops.Half.OPPONENTS)


func test_hotseat_hidden_draws_never_fill_the_showcase() -> void:
	_stand(0)
	screen.game.draw_cards(0, 1)
	assert_true(screen._card_preview._back.visible)
	_hand(0).toggle_button.pressed.emit()
	screen.game.draw_cards(1, 1)
	assert_true(screen._card_preview._back.visible, "the other player's draw stays private")
	screen.game.draw_cards(0, 1)
	assert_false(screen._card_preview._back.visible, "a deliberately revealed hand may preview its draw")
	_hand(0).toggle_button.pressed.emit()
	assert_true(screen._card_preview._back.visible)


func test_hiding_a_private_choice_keeps_the_engine_question_unanswered() -> void:
	_stand(1)
	var choice := PlayerChoice.new(PlayerChoice.Kind.DISCARD, 1, "Choose a card.")
	choice.count = 1
	choice.candidates.assign(screen.game.players[1].hand)
	screen.game.awaiting_choice = choice
	screen._refresh()
	assert_null(screen._choice_overlay)
	_hand(1).toggle_button.pressed.emit()
	# Headless skips dialog opening; construct the exact same native overlay.
	screen._build_choice_overlay(choice)
	var overlay := screen._choice_overlay
	var hide_button := overlay.get_node("HidePrivateHand") as Button
	assert_eq(hide_button.global_position, _hand(1).toggle_button.global_position)
	hide_button.pressed.emit()
	assert_null(screen._choice_overlay)
	assert_false(overlay.visible, "no frame or closing fade discloses private options")
	assert_eq(screen.game.awaiting_choice, choice)
	assert_false(_hand(1).revealed)


func test_each_stack_drags_with_its_button_and_keeps_its_own_position(pid = use_parameters([0, 1])) -> void:
	_stand(pid)
	var hand := _hand(pid)
	var other := _hand(1 - int(pid))
	assert_false(hand.pinned)
	assert_eq(hand.get_parent(), screen, "hand floats, no container can reset its position")
	var before := hand.position
	var other_before := other.position
	var button_offset := hand.toggle_button.global_position - hand.global_position
	var saved := Settings.hand_stack_pos()
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(StackHand.WIDTH / 2.0, StackHand.BAR_HEIGHT / 2.0)
	press.global_position = hand._title_bg.global_position + press.position
	hand._on_title_input(press)
	var move := InputEventMouseMotion.new()
	move.global_position = press.global_position + Vector2(-180, 32)
	hand._on_title_input(move)
	press.pressed = false
	press.global_position = move.global_position
	hand._on_title_input(press)
	assert_eq(hand.position, before + Vector2(-180, 32))
	assert_eq(hand.toggle_button.global_position - hand.global_position, button_offset)
	assert_eq(other.position, other_before)
	var dragged := hand.position
	hand.toggle_button.pressed.emit()
	hand.toggle_button.pressed.emit()
	screen._refresh()
	await get_tree().process_frame
	assert_eq(hand.position, dragged, "reveal/hide and refresh never reset the dragged corner")
	assert_eq(Settings.hand_stack_pos(), saved, "neither seat overwrites the solo hand preference")
	hand.position = screen.get_viewport_rect().size
	hand._clamp_on_screen()
	assert_true(screen.get_viewport_rect().encloses(hand.toggle_button.get_global_rect()),
		"even an edge drag keeps the entire button on screen")


func test_hotseat_opening_hand_reconceals_for_the_next_player() -> void:
	var window := OpeningWindow.new()
	add_child_autofree(window)
	window.show_hand(screen.game, 0, "white", true)
	var hand := window.hand_window() as HotseatHand
	assert_false(hand.revealed)
	hand.toggle_button.pressed.emit()
	assert_true(hand.revealed)
	window.show_hand(screen.game, 1, "black", true)
	assert_false(hand.revealed)
	assert_eq(hand.seat, 1)
	assert_eq(hand.toggle_button.text, "Show hand")
	hand.toggle_button.pressed.emit()
	assert_true(hand.revealed)
	hand.toggle_button.pressed.emit()
	assert_false(hand.revealed)
	assert_false(window._examine.visible)
	await get_tree().process_frame
	assert_true(Rect2(Vector2.ZERO, OpeningWindow.SIZE).encloses(window.hand_rect()),
		"the hand and its toggle fit within the opening window")


func _press(window: OpeningWindow, label: String) -> void:
	assert_true(window.press(label), "opening has a %s button" % label)
	await get_tree().process_frame
	await get_tree().process_frame


func test_private_opening_sequence_for_either_toss_winner(winner = use_parameters([0, 1])) -> void:
	var opening := OpeningHand.new()
	add_child_autofree(opening)
	# A separate dealt game, before either seat's mulligan has been settled.
	var dealt := MtgGame.new()
	dealt.setup(screen.config.decks[0], screen.config.decks[1], "A", "B", 20, 20, 92000)
	dealt.deal_opening_hands(7)
	opening.run(dealt, winner, func(_pid: int): return true, ["white", "black"], true)
	await get_tree().process_frame
	var window := opening.window()
	assert_string_contains(window.lead_text(), DuelConfig.seat_label(winner))
	var hand := window.hand_window() as HotseatHand
	assert_eq(hand.seat, winner)
	assert_false(hand.revealed)
	await _press(window, "Draw first")
	assert_string_contains(window.lead_text(), DuelConfig.seat_label(1 - int(winner)))
	hand.toggle_button.pressed.emit()
	assert_true(hand.revealed)
	await _press(window, "Take mulligan")
	assert_eq(dealt.players[winner].hand.size(), 6)
	assert_true(hand.revealed, "the same player may inspect their redraw")
	await _press(window, "Start the duel")
	assert_eq(hand.seat, 1 - int(winner))
	assert_false(hand.revealed, "the next player explicitly reveals their own cards")
	hand.toggle_button.pressed.emit()
	assert_true(hand.revealed)
	await _press(window, "Start the duel")
	assert_eq(dealt.turn_number, 1)
	assert_eq(dealt.active_player, 1 - int(winner))
	assert_false(hand.revealed, "the opening hand is concealed before its closing fade")
	await get_tree().create_timer(0.5).timeout
