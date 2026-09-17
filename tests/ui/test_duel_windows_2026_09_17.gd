extends GameTest
## THE WINDOWS THE DUEL PUTS UP ANSWER FOR THEMSELVES — three defects that
## all come of a window being asked a question the table underneath it
## answered instead.
##
##   * `Give up this duel?` reached from the Pause window belongs to NO
##     territory ([method DuelScreen._on_pause_chosen] clears
##     `_territory_menu_pid`), and the fallback was [method
##     DuelScreen._human_seat] — which is ALWAYS seat 0 at a private
##     hotseat. Player 2 pressing `Q → Concede duel → Yes, I'm sure` gave
##     up PLAYER 1's seat and won the duel by conceding.
##   * Escape over that same question had no rung on the cancel ladder
##     ([method DuelScreen._on_escape]), and [method
##     DuelScreen._unhandled_key_input] routes the key there the moment a
##     dialog is up — so the question stood and the duel UNDER it was
##     peeled instead, un-declaring an attack the player had lined up.
##   * The `{X}` window is modal to the player but not to the AI seat's
##     dwell ([method DuelScreen._maybe_schedule_ai] waits only on Pause),
##     so a Titania's Song resolving under it empties the artifact's
##     `cur_activated_abilities` and the index the ability menu handed the
##     window is past the end of the list. OK read as an out-of-bounds
##     error rather than as a refusal.


var screen: DuelScreen


func _open(private: bool) -> void:
	screen = load("res://game/duel/duel_screen.tscn").instantiate()
	if private:
		screen.config = DuelConfig.hotseat_default()
		screen.config.hotseat_privacy = true
		screen.config.rng_seed = 92000
	add_child_autofree(screen)
	await get_tree().process_frame
	await get_tree().process_frame
	g = screen.game


func after_each() -> void:
	await get_tree().process_frame
	await get_tree().process_frame


func _stand(pid: int) -> void:
	g.active_player = pid
	g._enter_step(Mtg.STEP_ORDER.find(Mtg.Step.MAIN1))
	screen._refresh()


func _put(pid: int, card_name: String) -> CardInstance:
	var inst := CardInstance.new(CardRegistry.get_card(card_name),
		g._next_instance_id, pid)
	g._next_instance_id += 1
	g._instances[inst.id] = inst
	g._put_on_battlefield(inst, pid)
	inst.summoning_sick = false
	return inst


func test_the_pause_concede_gives_up_the_seat_that_pressed_it(
		pid = use_parameters([0, 1])) -> void:
	await _open(true)
	_stand(pid)
	assert_eq(screen._private_decision_seat(), int(pid),
		"the screen is serving the seat whose turn it is")
	screen._on_pause_chosen(DuelPause.Action.CONCEDE)
	screen._confirm_concede()
	assert_true(g.game_over)
	assert_eq(g.winner, 1 - int(pid),
		"the seat that conceded loses, whichever half of the table it sits in")


func test_escape_over_the_concede_question_answers_the_question() -> void:
	await _open(false)
	g.rules.attackers_revocable = true
	var bear := _put(0, "Grizzly Bears")
	_stand(0)
	g._enter_step(Mtg.STEP_ORDER.find(Mtg.Step.DECLARE_ATTACKERS))
	screen._refresh()
	assert_eq(screen.mode, DuelScreen.Mode.ATTACKERS)
	screen._on_card_clicked(bear)
	assert_eq(screen._selected_attackers, [bear.id])
	screen._ask_to_concede()
	var key := InputEventKey.new()
	key.keycode = KEY_ESCAPE
	key.pressed = true
	screen._unhandled_key_input(key)
	assert_null(screen._concede_dialog, "Escape answers the window that is up")
	assert_eq(screen._selected_attackers, [bear.id],
		"and never the duel underneath it")
	assert_false(g.game_over, "and nothing was conceded")


func test_escape_over_the_duel_options_panel_closes_the_panel() -> void:
	await _open(false)
	_stand(0)
	screen._open_duel_options()
	assert_not_null(screen._options_dialog)
	var key := InputEventKey.new()
	key.keycode = KEY_ESCAPE
	key.pressed = true
	screen._unhandled_key_input(key)
	assert_null(screen._options_dialog, "the panel has its own OK, and Esc is it")


func test_the_x_window_survives_its_ability_being_silenced() -> void:
	await _open(false)
	var lamp := _put(0, "Candelabra of Tawnos")
	_put(0, "Forest")
	assert_eq(lamp.cur_activated_abilities.size(), 1)
	screen._open_ability_menu(lamp)
	screen._ability_menu.hide()
	screen._on_ability_chosen(lamp.cur_mana_abilities.size())
	assert_not_null(screen._x_dialog, "the {X} question is up")
	# The AI seat plays on under the window: Titania's Song strips every
	# noncreature artifact of its abilities (CR 613 layer 6).
	_put(1, "Titania's Song")
	g.recalculate()
	assert_eq(lamp.cur_activated_abilities.size(), 0, "the Song silenced it")
	screen._on_x_confirmed()
	assert_null(screen._pending_card,
		"the activation is withdrawn, not answered out of bounds")
	assert_null(screen._x_dialog)
