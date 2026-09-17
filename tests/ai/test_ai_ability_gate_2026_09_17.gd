extends GameTest
## THE GATE TWO ARMS NEVER ASKED (2026-09-17).
##
## [method AiPlayer._ability_available] is the one place this AI reads an
## activated ability's COST RIDERS (a body, three taps, a counter, a life
## point) and its TIMING against the engine's own refusals. Two arms of
## [AiPlayer] reached [method MtgGame.activate_ability] without it — one
## spending riders nothing had priced, one paying the mana for an
## activation the engine was always going to refuse.
##
## ------------------------------------------------------------------------
## 1. THE PRICE THE EXECUTIONER NEVER PAID.
##
## [method AiPlayer._defensive_combat_response]'s activated-removal arm —
## "Royal Assassin executes a tapped attacker" — walked the battlefield
## looking only at the SHAPE of an ability (a tap cost, one
## [DestroyEffect], a legal target) and then activated it. Every sibling
## loop in that file asks [method AiPlayer._ability_available] first
## ([method AiPlayer._animate_to_block], the firebreathing pass, [method
## AiPlayer._shield], [method AiPlayer._regenerate]), and that gate is the
## one place the AI's capability knobs and the engine's own cost riders
## are read. Without it the arm spends what the scorer would have PRICED
## ([method AiPlayer._sacrifice_price]: a body at [method
## AiPlayer._own_value], a tapped permanent at 0.75 each) for free:
##
##   * Hand of Justice — *"{T}, Tap three untapped white creatures you
##     control: Destroy target creature"* — taps three of its own bodies
##     at DECLARE ATTACKERS, before blocks, to kill ONE attacker;
##   * Viscerid Drone — *"{T}, Sacrifice a creature and a Swamp"* — eats
##     a creature and a land, on a Magician, whose
##     [member AiProfile.pays_sacrifices] is OFF precisely so that it
##     cannot.
##
## Both are the failure `_ability_available`'s own comments name ("must
## stay invisible or it eats the board one Serra at a time"), reached
## through the one loop that never asked it.
##
## ------------------------------------------------------------------------
## 2. THE SHIELD THAT WAS ALREADY TAPPED.
##
## [method AiPlayer._spend_on_packet] — the damage window's own spender —
## ranked battlefield abilities by mana value alone and never asked
## whether the permanent could be activated at all. A TAPPED Pentagram of
## the Ages (*"{4}, {T}: ..."*) was therefore chosen, four lands were
## tapped for it, and [method MtgGame.activate_ability] answered *"is
## already tapped"* — a refusal the window could not have provoked, with
## the four mana left floating for the step to throw away (or, with the
## 1997 mana-burn fork on, for four life). It is the shape
## `docs/ROADMAP.md` carried unreproduced as *"two tactics lines pay mana
## before a refusal they cannot provoke"*, in the window rather than in a
## tactics file.


func before_each() -> void:
	for id in CardPacks.available_ids():
		CardPacks.set_enabled(id, true)
	super()


func after_each() -> void:
	g = null
	for id in CardPacks.available_ids():
		CardPacks.set_enabled(id, false)


## A Magician seat 0: reactive (it reaches the defensive response) but with
## neither [member AiProfile.pays_sacrifices] nor
## [member AiProfile.times_sweeps], so the priced scorer is not in the way
## and the arm under test is the only thing that can act.
func _magician() -> AiPlayer:
	var pilot := AiPlayer.new(0, AiProfile.magician())
	g.set_agent(0, pilot)
	return pilot


## Walk to THEIR declare-attackers, declare [param attackers], and stop on
## our priority inside the step.
func _they_attack(attackers: Array) -> void:
	var guard := 0
	while (not g.awaiting_attackers or g.active_player != 1) \
			and not g.game_over and guard < 200:
		if g.awaiting_attackers:
			assert_ok(g.declare_attackers(g.active_player, []))
		elif g.awaiting_blockers:
			assert_ok(g.declare_blockers(g.opponent_of(g.active_player), {}))
		else:
			assert_ok(g.pass_priority(g.priority_player))
		guard += 1
	assert_true(g.awaiting_attackers, "reached their declaration")
	assert_ok(g.declare_attackers(1, attackers))
	resolve_stack()
	guard = 0
	while g.priority_player != 0 and not g.game_over and guard < 20:
		assert_ok(g.pass_priority(g.priority_player))
		guard += 1
	assert_eq(g.priority_player, 0, "and it is our priority in the step")


func test_the_executioner_does_not_tap_three_bodies_for_nothing() -> void:
	var pilot := _magician()
	put_battlefield(0, "Hand of Justice")
	var guards: Array[CardInstance] = []
	for _i in 3:
		guards.append(put_battlefield(0, "White Knight"))
	var wurm := put_battlefield(1, "Craw Wurm")
	_they_attack([wurm.id])
	pilot._defensive_combat_response(g)
	for guard in guards:
		assert_false(guard.tapped,
			"three white creatures are a price, not a free cost")
	assert_eq(wurm.zone, Mtg.Zone.BATTLEFIELD,
		"and the execution was never announced")


func test_the_executioner_does_not_eat_a_body_a_magician_may_not_spend() -> void:
	var pilot := _magician()
	assert_false(pilot.profile.pays_sacrifices,
		"the fixture's whole point: this seat may not pay a body")
	put_battlefield(0, "Viscerid Drone")
	var angel := put_battlefield(0, "Serra Angel")
	var swamp := put_battlefield(0, "Swamp")
	var wurm := put_battlefield(1, "Craw Wurm")
	_they_attack([wurm.id])
	pilot._defensive_combat_response(g)
	assert_eq(angel.zone, Mtg.Zone.BATTLEFIELD, "the Angel is still ours")
	assert_eq(swamp.zone, Mtg.Zone.BATTLEFIELD, "and so is the Swamp")
	assert_eq(wurm.zone, Mtg.Zone.BATTLEFIELD,
		"and the execution was never announced")


## THE POSITIVE CONTROL: the arm the loop was written for still fires.
## Royal Assassin's ability costs a tap and nothing else, so the gate lets
## it through and the tapped attacker dies.
func test_the_royal_assassin_still_executes_a_tapped_attacker() -> void:
	var pilot := _magician()
	put_battlefield(0, "Royal Assassin")
	var wurm := put_battlefield(1, "Craw Wurm")
	_they_attack([wurm.id])
	assert_string_contains(pilot._defensive_combat_response(g), "Royal Assassin")
	resolve_stack()
	assert_eq(wurm.zone, Mtg.Zone.GRAVEYARD, "the attacker is executed")


# ------------------------------------------- 2. the shield already tapped --

## Arm both gates of the 1997 damage window for [param seat]: the rules
## fork and an AI that asks for it (`tests/ai/test_ai_prevention.gd`).
func _windowed(seat: int) -> AiPlayer:
	g.rules.damage_prevention_window = true
	var pilot := AiPlayer.new(seat, AiProfile.wizard())
	g.set_agent(seat, pilot)
	return pilot


## Walk to the open window with [param attackers] swinging at seat 1, and
## stop on seat 1's own priority inside it.
func _into_the_window(attackers: Array) -> void:
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, attackers))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {}))
	advance_to_step(Mtg.Step.COMBAT_DAMAGE)
	assert_true(g.awaiting_damage_prevention, "the window is open")
	var guard := 0
	while g.priority_player != 1 and guard < 8:
		assert_ok(g.pass_priority(g.priority_player))
		guard += 1
	assert_eq(g.priority_player, 1, "and the window is ours")


func test_a_tapped_shield_does_not_swallow_the_mana_it_tapped_for() -> void:
	var pilot := _windowed(1)
	g.players[1].life = 6
	var pentagram := put_battlefield(1, "Pentagram of the Ages")
	for _i in 4:
		put_battlefield(1, "Forest")
	var giant := put_battlefield(0, "Hill Giant")
	g.tap_permanent(pentagram)   # spent earlier in the turn
	_into_the_window([giant.id])
	pilot.act(g)
	assert_eq(g.players[1].mana_pool.total(), 0,
		"a refusal the window cannot provoke must not cost four lands")
	assert_true(pentagram.tapped, "and the shield is still spent")


## THE POSITIVE CONTROL: untapped, the same Pentagram is bought, and the
## mana that was tapped for it is the mana the ability spends.
func test_an_untapped_shield_is_still_bought_with_four_lands() -> void:
	var pilot := _windowed(1)
	g.players[1].life = 6
	var pentagram := put_battlefield(1, "Pentagram of the Ages")
	for _i in 4:
		put_battlefield(1, "Forest")
	var giant := put_battlefield(0, "Hill Giant")
	_into_the_window([giant.id])
	assert_ne(pilot.act(g), "", "the window spends on the packet")
	assert_true(pentagram.tapped, "the shield was activated")
	assert_eq(g.players[1].mana_pool.total(), 0, "and the mana went into it")
