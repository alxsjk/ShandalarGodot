extends GameTest
## A REFUSED answer leaves the same question open. The shared screen's own
## overlay resets its picks when it answers; the online one only resets them
## when the question's DTO changes — and a refusal changes nothing — so the
## click that should answer toggled the standing pick off instead.

var referee: SgPracticeMatch
var revision := 1
var commands: Array = []
var refusals: Array = []
var refuse_once := ""


func before_each() -> void:
	super.before_each()
	referee = SgPracticeMatch.new(42)
	referee.game = g
	revision = 1
	commands.clear()
	refusals.clear()
	refuse_once = ""
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


## The transport's own refusal path: the lobby hands `client.refused` to the
## duel view, which is exactly what a stale room revision produces.
func _act(action: Dictionary, screen: SgDuelView, seat: int) -> void:
	commands.append(action.duplicate(true))
	var error := refuse_once
	refuse_once = ""
	if error.is_empty(): error = referee.act(seat, action)
	if not error.is_empty():
		refusals.append(error)
		screen.show_notice(error)
	else: revision += 1
	screen.present.call_deferred(_room(seat), true, false)


func _pump() -> void:
	for i in 8: await get_tree().process_frame


func _local(screen: SgDuelView, card: CardInstance) -> CardInstance:
	return screen.game.find_instance(screen.projection.local_id(referee._handle(int(screen._room.seat), card)))


func test_a_refused_answer_can_be_given_again_with_one_click() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var tutor := give_hand(0, "Demonic Tutor")
	add_mana(0, Mtg.ManaColor.B, 2)
	var screen := _screen()
	screen._on_card_clicked(_local(screen, tutor))
	await _pump()
	for i in 4:
		if g.awaiting_choice != null: break
		assert_ok(g.pass_priority(g.priority_player))
	revision += 1
	screen.present(_room(), true, false)
	assert_not_null(screen._choice_overlay)
	refuse_once = "The room changed. Please try again."
	screen._on_choice_option(0)
	await _pump()
	assert_eq(refusals, ["The room changed. Please try again."])
	assert_not_null(g.awaiting_choice, "the refused answer never reached the referee")
	screen._on_choice_option(0)
	await _pump()
	assert_null(g.awaiting_choice, "the same click answers the still-open question")
	assert_eq(g.players[0].hand.size(), 1, "the tutored card reached the hand")
	if not g.players[0].hand.is_empty():
		assert_eq(g.players[0].hand.back().data.card_name, "Forest")
