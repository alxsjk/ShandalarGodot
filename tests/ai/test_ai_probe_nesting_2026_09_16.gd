extends GameTest
## A SEARCH INSIDE THE ENGINE'S OWN PROBE (2026-09-16).
##
## `docs/duel-todo.md` §1.3's pre-flight resolves the top of the stack once
## over a [GameSnapshot] to find out what it will ASK, and rewinds. While it
## runs, [member MtgGame._probing] suppresses the log, the state signal, the
## reveals and the choice ledger, because a listener's reaction cannot be
## rewound.
##
## The probe asks the seat's own agent, and since the 2026-09-13 planning
## work a strategy answers those questions by VALUING THE BOARD:
## [AiContextValue] lifts a permanent out through
## [method MtgGame.value_without_permanent], the tactical scorers call
## [method MtgGame.forecast_damage], and both open a search of their own —
## with the engine already probing and no journal yet.
## [method MtgGame.end_search] used to hand the game back with
## `_probing = false` unconditionally, so the REST of the engine's probe ran
## unprobed: every log line, state signal and reveal it produced reached the
## duel screen before the snapshot threw the run away. With a human at the
## table the player saw "Lightning Bolt is redirected to ..." twice.
##
## Both halves are pinned here: the invariant (a nested search gives probe
## mode back) and the symptom (the screen sees one line, not two).
##
## The recorder below is deliberately a STATIC: [GameSnapshot] captures
## every object the game can reach, its agents included, so a count kept on
## the agent instance is rewound with everything else and the probe's own
## call would vanish with it.


func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()


func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)


## A seat that answers by searching, and records whether the engine was
## still probing on the way out. No AI policy here — this is the smallest
## agent that does what [AiPlayer] does at the same moment.
class SearchingAgent extends DecisionAgent:
	static var pairs: Array = []

	func answer_option(game: MtgGame, _pid: int, _prompt: String,
			_options: Array[String], hint: int) -> int:
		var before := game.is_probing()
		game.forecast_damage(true)
		pairs.append([before, game.is_probing()])
		return hint


## Seat 1 bolts one of seat 0's creatures; seat 0 answers with Deflection,
## whose resolution asks which target to move the bolt to. A human seat is
## what turns the pre-flight on. Returns every line the screen was handed.
func _bolt_under_deflection(seat_zero: DecisionAgent) -> Array[String]:
	var mine := put_battlefield(0, "Grizzly Bears")
	put_battlefield(0, "Hill Giant")
	for _i in 4: put_battlefield(0, "Island")
	put_battlefield(1, "Mountain")
	g.set_agent(0, seat_zero)
	g.set_agent(1, HumanAgent.new())
	g.interactive_choices = true
	advance_to_step(Mtg.Step.MAIN1)
	var bolt := give_hand(1, "Lightning Bolt")
	add_mana(1, Mtg.ManaColor.R, 1)
	assert_ok(g.pass_priority(0))
	assert_ok(g.cast_spell(1, bolt, [TargetRef.card(mine)]))
	var deflection := give_hand(0, "Deflection")
	add_mana(0, Mtg.ManaColor.U, 4)
	assert_ok(g.pass_priority(1))
	assert_ok(g.cast_spell(0, deflection, [TargetRef.card(bolt)]))
	var emitted: Array[String] = []
	g.log_appended.connect(func(msg: String, _meta: Dictionary) -> void:
		emitted.append(msg))
	var guard := 0
	while not g.stack.is_empty() and guard < 40:
		assert_ok(g.pass_priority(g.priority_player))
		guard += 1
	assert_lt(guard, 40, "the stack must empty")
	return emitted


func test_a_search_started_inside_a_probe_gives_probe_mode_back() -> void:
	SearchingAgent.pairs = []
	var agent := SearchingAgent.new()
	var record: Array = SearchingAgent.pairs
	_bolt_under_deflection(agent)
	assert_gt(record.size(), 1, "the pre-flight and the resolution both asked")
	for pair in record:
		assert_eq(pair[1], pair[0], "end_search must not clear an outer probe")
	assert_false(g.is_probing())
	assert_null(g.undo_log)


func test_the_pilots_own_valuation_does_not_double_the_duel_log() -> void:
	var pilot := AiPlayer.new(0, AiProfile.wizard())
	# The valuation that opens the nested search: a lift-out of a creature
	# whose static ability is worth something to the rest of the board.
	put_battlefield(0, "Lord of Atlantis")
	var emitted := _bolt_under_deflection(pilot)
	var screen := 0
	var kept := 0
	for msg in emitted:
		if "redirected" in msg: screen += 1
	for msg in g.log_lines:
		if "redirected" in msg: kept += 1
	assert_eq(kept, 1, "the redirect happened once")
	assert_eq(screen, kept, "the screen saw exactly the lines the duel kept")
