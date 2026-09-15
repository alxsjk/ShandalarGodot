extends GameTest
## The online adapter preserves the shared table's appearance and presentation timing.

class ResultTable extends SgDuelView:
	var life_before_result: Array = []
	func _on_game_over(winner_id: int) -> void:
		life_before_result = _last_life.duplicate()
		super._on_game_over(winner_id)

var referee: SgPracticeMatch

func before_each() -> void:
	super.before_each()
	referee = SgPracticeMatch.new(42)
	referee.game = g

func _room(seat := 0) -> Dictionary:
	return {"id":"r1", "name":"Visual parity", "seat":seat,
		"names":["Azure Fox", "Amber Owl"], "revision":1, "ready":[true,true],
		"connected":[true,true], "game":referee.view(seat),
		"deck_names":referee.deck_names.duplicate(), "deck":{}}

func _screen(seat := 0) -> ResultTable:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 800)
	add_child_autofree(viewport)
	var screen := ResultTable.new()
	screen.stops.from_masks(PackedInt32Array([255,255,255,255]))
	viewport.add_child(screen)
	screen.present(_room(seat), true, false)
	return screen

func test_online_uses_the_registered_decks_public_colors_for_either_seat() -> void:
	referee = SgPracticeMatch.new(42, [
		{"name":"Knights", "cards":Array(StarterDecks.WHITE_KNIGHTS), "sideboard":[]},
		{"name":"Raiders", "cards":Array(StarterDecks.BLACK_RED_RAIDERS), "sideboard":[]}])
	referee.game.start_duel(0)
	var expected := [DuelConfig.dominant_color(Array(StarterDecks.WHITE_KNIGHTS)),
		DuelConfig.dominant_color(Array(StarterDecks.BLACK_RED_RAIDERS))]
	for seat in 2:
		var screen := _screen(seat)
		assert_eq(Array(screen.config.panel_colors), [expected[seat], expected[1 - seat]])
		assert_eq(screen.config.decks[1], [], "cosmetic metadata must not include the opposing deck")

func test_command_waits_preserve_combat_instructions() -> void:
	var attacker := put_battlefield(0, "Grizzly Bears")
	put_battlefield(1, "Gray Ogre")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	var screen := _screen(1)
	var prompt: String = screen._prompt_label.text
	assert_string_contains(prompt, "Choose blockers")
	screen.present(_room(1), true, true)
	assert_eq(screen._prompt_label.text, prompt, "an ordinary acknowledgement wait must not replace a phase instruction")
	assert_true(screen._pass_button.disabled)
	assert_eq(screen._network_badge.text, "Sending…")
	screen.present(_room(1), false, false)
	assert_eq(screen._prompt_label.text, prompt)
	assert_eq(screen._network_badge.text, "Reconnect")

func test_opponent_disconnect_preserves_prompt_and_names_waiting_player() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var screen := _screen()
	var prompt: String = screen._prompt_label.text
	var room := _room()
	room.connected[1] = false
	screen.present(room, true, false)
	assert_eq(screen._prompt_label.text, prompt)
	assert_eq(screen._network_badge.text, "Suspended")
	assert_string_contains(screen._network_badge.tooltip_text, "Amber Owl")

func test_result_runs_before_refresh_overwrites_the_previous_life_total() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var screen := _screen()
	var previous := g.players[1].life
	g.adjust_life(1, -22)
	assert_true(g.game_over)
	screen.present(_room(), true, false)
	assert_eq(screen.life_before_result[1], previous, "the local countdown needs the last painted life, not the final total")
	assert_true(screen._result_seen)
	screen.present(_room(), true, false)
	assert_eq(screen.life_before_result[1], previous, "a duplicate snapshot must not restart the result")

func test_opening_buttons_survive_snapshot_and_busy_updates() -> void:
	referee = SgPracticeMatch.new(42)
	var screen := _screen()
	var opening := screen._network_opening
	assert_not_null(opening)
	var first: Button = opening._buttons[0]
	var second: Button = opening._buttons[1]
	screen.present(_room(), true, true)
	assert_same(opening._buttons[0], first)
	assert_same(opening._buttons[1], second)
	assert_true(first.disabled and second.disabled)
	screen.present(_room(), true, false)
	assert_same(opening._buttons[0], first)
	assert_same(opening._buttons[1], second)

func test_public_palette_is_stable_and_rejects_unknown_skin_values() -> void:
	var original: Array = referee.view(0).presentation.players.duplicate(true)
	give_hand(1, "Black Lotus")
	g.players[1].library.reverse()
	var snapshot := referee.view(0)
	assert_eq(snapshot.presentation.players, original)
	assert_false(JSON.stringify(snapshot).contains("Black Lotus"))
	for bad_value in ["../portrait", "neon", 42]:
		var invalid := snapshot.duplicate(true)
		invalid.presentation.players[0].color = bad_value
		assert_false(SgViewProtocol.game(invalid))

func test_connection_dialog_updates_without_reopening() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var screen := _screen()
	screen._show_connection()
	var label := screen._connection_status
	assert_string_contains(label.text, "Connected")
	screen.present(_room(), false, false)
	assert_same(screen._connection_status, label)
	assert_string_contains(label.text, "Reconnecting")
	var room := _room()
	room.connected[1] = false
	screen.present(room, true, false)
	assert_string_contains(label.text, "Amber Owl")

func test_first_snapshot_of_a_finished_duel_has_no_invented_previous_life() -> void:
	g.adjust_life(1, -22)
	assert_true(g.game_over)
	var screen := _screen()
	assert_eq(screen.life_before_result, [g.players[0].life, g.players[1].life])
	assert_true(screen._result_seen)

func test_connection_status_uses_the_remote_seat_mapping() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var screen := _screen(1)
	var room := _room(1)
	room.connected[0] = false
	screen.present(room, true, false)
	assert_string_contains(screen._connection_message(), "Azure Fox")
	room.connected = [true, false]
	screen.present(room, true, false)
	assert_string_contains(screen._connection_message(), "Restoring your seat")

func test_restored_combat_fits_the_board_after_layout_and_resize() -> void:
	var attacker := put_battlefield(0, "Grizzly Bears")
	put_battlefield(1, "Gray Ogre")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	var screen := _screen(1)
	for i in 8: await get_tree().process_frame
	var combat := screen._combat_window
	assert_true(combat.visible)
	_assert_combat_inside_board(screen)
	var card: Node = combat._top_lane.get_child(0)
	var prompt: String = screen._prompt_label.text
	(screen.get_parent() as SubViewport).size = Vector2i(1100, 700)
	for i in 8: await get_tree().process_frame
	_assert_combat_inside_board(screen)
	assert_same(combat._top_lane.get_child(0), card, "layout correction must not rebuild the combat cards")
	assert_eq(screen._prompt_label.text, prompt)

func _assert_combat_inside_board(screen: SgDuelView) -> void:
	var board: Rect2 = screen._board_area()
	var combat: Rect2 = screen._combat_window.get_global_rect()
	assert_gte(combat.position.x, board.position.x, "the combat title must stay clear of the sidebar")
	assert_lte(combat.end.x, board.end.x)
	assert_almost_eq(combat.get_center().x, board.get_center().x, 1.0)
