extends GameTest
## The six-case Forge audit's tactical regressions, through the public pilot.


func _wizard(seat: int, enabled := true) -> AiPlayer:
	var ai := AiPlayer.new(seat, AiProfile.wizard())
	ai.profile.forecasts_tactics = enabled
	g.set_agent(seat, ai)
	return ai


func _blocks(attacker: CardInstance, blocker: CardInstance = null) -> void:
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {} if blocker == null else {blocker.id: attacker.id}))


func test_mass_protection_saves_a_creature_from_burn_in_both_editions() -> void:
	for edition in ["modern", "fifth"]:
		before_each()
		g.rules.set_edition(edition)
		var ai := _wizard(0)
		var specter := put_battlefield(0, "Hypnotic Specter")
		give_hand(0, "Shield Wall")
		put_battlefield(0, "Plains")
		put_battlefield(0, "Plains")
		var bolt := give_hand(1, "Lightning Bolt")
		advance_to_step(Mtg.Step.MAIN1)
		assert_ok(g.pass_priority(0))
		add_mana(1, Mtg.ManaColor.R)
		assert_ok(g.cast_spell(1, bolt, [TargetRef.card(specter)]))
		assert_ok(g.pass_priority(1))
		assert_string_contains(ai.act(g), "Shield Wall", edition)
		resolve_stack()
		advance_to_step(Mtg.Step.COMBAT_BEGIN)
		assert_eq(specter.zone, Mtg.Zone.BATTLEFIELD)
		assert_eq(specter.damage, 3)


func test_mass_debuff_stops_lethal_trample() -> void:
	var ai := _wizard(1)
	g.players[1].life = 6
	advance_to_step(Mtg.Step.MAIN1)
	var force := put_battlefield(0, "Force of Nature")
	var bear := put_battlefield(1, "Grizzly Bears")
	give_hand(1, "Marsh Gas")
	put_battlefield(1, "Swamp")
	_blocks(force, bear)
	assert_ok(g.pass_priority(0))
	assert_string_contains(ai.act(g), "Marsh Gas")
	resolve_stack()
	advance_to_step(Mtg.Step.COMBAT_END)
	assert_eq(g.players[1].life, 2)
	assert_false(g.game_over)


func test_minor_tactical_response_preserves_more_valuable_held_mana() -> void:
	var ai := _wizard(0)
	ai.profile.ranks_counters = false
	ai.profile.counter_threshold = 20.0
	var specter := put_battlefield(0, "Hypnotic Specter")
	give_hand(0, "Shield Wall")
	give_hand(0, "Counterspell")
	var land := put_battlefield(0, "Tundra")
	put_battlefield(0, "Tundra")
	var bolt := give_hand(1, "Lightning Bolt")
	advance_to_step(Mtg.Step.MAIN1)
	assert_ok(g.pass_priority(0))
	add_mana(1, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(1, bolt, [TargetRef.card(specter)]))
	assert_ok(g.pass_priority(1))
	assert_eq(ai.act(g), "pass")
	assert_false(land.tapped)
	assert_not_null(g.find_in_hand(0, "Shield Wall"))


func test_lifesaving_response_may_spend_reserved_mana() -> void:
	var ai := _wizard(1)
	ai.profile.counter_threshold = 20.0
	g.players[1].life = 6
	advance_to_step(Mtg.Step.MAIN1)
	var force := put_battlefield(0, "Force of Nature")
	var bear := put_battlefield(1, "Grizzly Bears")
	give_hand(1, "Marsh Gas")
	give_hand(1, "Counterspell")
	put_battlefield(1, "Underground Sea")
	put_battlefield(1, "Underground Sea")
	_blocks(force, bear)
	assert_ok(g.pass_priority(0))
	assert_string_contains(ai.act(g), "Marsh Gas")


func test_fog_already_protects_the_defender() -> void:
	var ai := _wizard(1)
	g.players[1].life = 4
	var dragon := put_battlefield(0, "Shivan Dragon")
	give_hand(1, "Marsh Gas")
	put_battlefield(1, "Swamp")
	_blocks(dragon)
	var fog := give_hand(0, "Fog")
	add_mana(0, Mtg.ManaColor.G)
	assert_ok(g.cast_spell(0, fog, []))
	resolve_stack()
	assert_ok(g.pass_priority(0))
	assert_eq(ai.act(g), "pass")
	assert_not_null(g.find_in_hand(1, "Marsh Gas"))


func test_first_strike_already_dealt_is_not_counted_twice() -> void:
	var ai := _wizard(1)
	var knight := put_battlefield(0, "White Knight")
	var giant := put_battlefield(1, "Hill Giant")
	give_hand(1, "Shield Wall")
	put_battlefield(1, "Plains")
	put_battlefield(1, "Plains")
	_blocks(knight, giant)
	advance_to_step(Mtg.Step.FIRST_STRIKE_DAMAGE)
	assert_eq(giant.damage, 2)
	assert_ok(g.pass_priority(0))
	assert_eq(ai.act(g), "pass")
	assert_not_null(g.find_in_hand(1, "Shield Wall"))
	advance_to_step(Mtg.Step.COMBAT_END)
	assert_eq(giant.zone, Mtg.Zone.BATTLEFIELD)


func test_null_preserves_the_old_missed_trample_response() -> void:
	var ai := _wizard(1, false)
	g.players[1].life = 6
	advance_to_step(Mtg.Step.MAIN1)
	var force := put_battlefield(0, "Force of Nature")
	var bear := put_battlefield(1, "Grizzly Bears")
	give_hand(1, "Marsh Gas")
	put_battlefield(1, "Swamp")
	_blocks(force, bear)
	assert_ok(g.pass_priority(0))
	assert_eq(ai.act(g), "pass")
	assert_not_null(g.find_in_hand(1, "Marsh Gas"))


func test_a_card_without_enough_toughness_to_save_the_victim_is_held() -> void:
	var ai := _wizard(0)
	var specter := put_battlefield(0, "Hypnotic Specter")
	give_hand(0, "Shield Wall")
	put_battlefield(0, "Plains")
	put_battlefield(0, "Plains")
	var blast := give_hand(1, "Psionic Blast")
	advance_to_step(Mtg.Step.MAIN1)
	assert_ok(g.pass_priority(0))
	add_mana(1, Mtg.ManaColor.U, 3)
	assert_ok(g.cast_spell(1, blast, [TargetRef.card(specter)]))
	assert_ok(g.pass_priority(1))
	assert_eq(ai.act(g), "pass", "four toughness still dies to four damage")


func test_presets_enable_the_forecast_and_bare_profile_is_null() -> void:
	assert_false(AiProfile.new().forecasts_tactics)
	for profile in [AiProfile.apprentice(), AiProfile.magician(), AiProfile.sorcerer(), AiProfile.wizard()]:
		assert_true(profile.forecasts_tactics)


func test_paid_prevention_is_not_bought_for_unpreventable_damage() -> void:
	for edition in ["modern", "fifth"]:
		before_each()
		g.rules.set_edition(edition)
		var ai := _wizard(1)
		var giant := put_battlefield(0, "Hill Giant")
		var bear := put_battlefield(1, "Grizzly Bears")
		var land := put_battlefield(1, "Plains")
		put_battlefield(1, "Plains")
		g.grant_paid_prevention(1, TargetRef.card(bear), "Guardian Angel")
		bear.damage_unpreventable_this_turn = true
		_blocks(giant, bear)
		assert_ok(g.pass_priority(0))
		assert_eq(ai.act(g), "pass", edition)
		assert_false(land.tapped)
		assert_eq(bear.prevention, 0)
		assert_eq(ai._buy_prevention(g, TargetRef.card(bear), 2), "")
		assert_false(land.tapped, "the paid rider obeys the same restriction in the window")
