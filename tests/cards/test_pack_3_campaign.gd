extends GameTest
## Second-pass public-action regressions: incarnation continuity and real
## Ice Age damage decisions. See docs/pack-3-gameplay-campaign.md.

func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()

func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)

func pilot() -> AiPlayer:
	var ai := AiPlayer.new(0, AiProfile.wizard())
	ai.profile.develops_late = false
	g.agents[0] = ai
	return ai

func combat_pair() -> Array[CardInstance]:
	var attacker := put_battlefield(0, "Scaled Wurm")
	var blocker := put_battlefield(1, "Wall of Stone")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {blocker.id: attacker.id}))
	return [attacker, blocker]

func blink(body: CardInstance) -> void:
	var who := body.controller_id
	g.return_to_hand(body)
	g.put_from_hand_into_play(body, who)

func breath(body: CardInstance) -> void:
	var spell := give_hand(0, "Venomous Breath")
	g.priority_player = 0
	add_mana(0, Mtg.ManaColor.G, 4)
	assert_ok(g.cast_spell(0, spell, [TargetRef.card(body)]))
	resolve_stack()

func test_breath_does_not_destroy_blocker_returned_before_cast() -> void:
	var pair := combat_pair()
	blink(pair[1])
	breath(pair[0])
	g.dispatch_event(Mtg.EventType.END_OF_COMBAT, {"player": 0})
	resolve_stack()
	assert_eq(pair[1].zone, Mtg.Zone.BATTLEFIELD, "new blocker incarnation did not fight")

func test_breath_does_not_destroy_blocker_returned_after_cast() -> void:
	var pair := combat_pair()
	breath(pair[0])
	blink(pair[1])
	g.dispatch_event(Mtg.EventType.END_OF_COMBAT, {"player": 0})
	resolve_stack()
	assert_eq(pair[1].zone, Mtg.Zone.BATTLEFIELD, "delayed destruction must not follow a blink")

func test_breath_does_not_destroy_attacker_returned_before_cast_on_blocker() -> void:
	var pair := combat_pair()
	blink(pair[0])
	breath(pair[1])
	g.dispatch_event(Mtg.EventType.END_OF_COMBAT, {"player": 0})
	resolve_stack()
	assert_eq(pair[0].zone, Mtg.Zone.BATTLEFIELD, "new attacker incarnation did not fight")

func test_battle_cry_trigger_does_not_pump_a_returned_blocker() -> void:
	var attacker := put_battlefield(0, "Scaled Wurm")
	var blocker := put_battlefield(1, "Wall of Stone")
	advance_to_step(Mtg.Step.MAIN1)
	var spell := give_hand(0, "Battle Cry")
	add_mana(0, Mtg.ManaColor.W, 3)
	assert_ok(g.cast_spell(0, spell))
	resolve_stack()
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {blocker.id: attacker.id}))
	assert_false(g.stack.is_empty())
	blink(blocker)
	resolve_stack()
	assert_eq(blocker.cur_toughness, 8, "the new Wall never triggered Battle Cry")

func test_breath_cast_before_blocks_remembers_a_marked_creature_that_died() -> void:
	var attacker := put_battlefield(0, "Grizzly Bears")
	var blocker := put_battlefield(1, "Scaled Wurm")
	advance_to_step(Mtg.Step.MAIN1)
	breath(attacker)
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {blocker.id: attacker.id}))
	advance_to_step(Mtg.Step.COMBAT_END)
	resolve_stack()
	assert_eq(attacker.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(blocker.zone, Mtg.Zone.GRAVEYARD, "Breath still destroys the surviving opponent")

func incoming_bolt() -> CardInstance:
	var bolt := give_hand(1, "Lightning Bolt")
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(1, bolt, [TargetRef.player(0)]))
	g.priority_player = 0
	give_hand(0, "Deflection")
	add_mana(0, Mtg.ManaColor.U, 4)
	return bolt

func test_ai_deflection_takes_lethal_instead_of_scratching_a_large_creature() -> void:
	put_battlefield(1, "Colossus of Sardia")
	advance_to_step(Mtg.Step.MAIN1)
	g.players[1].life = 3
	incoming_bolt()
	var ai := pilot()
	assert_eq(ai._respond_action(g), "cast Deflection")
	resolve_stack()
	assert_true(g.game_over, "a redirected Bolt should win now")
	assert_eq(g.winner, 0)

func test_ai_meteor_does_not_call_prevented_damage_lethal() -> void:
	var wall := put_battlefield(1, "Wall of Wood")
	put_battlefield(1, "Forest")
	put_battlefield(1, "Glacial Chasm")
	advance_to_step(Mtg.Step.MAIN1)
	g.players[1].life = 1
	assert_true(g.find_on_battlefield(1, "Glacial Chasm") != null)
	give_hand(0, "Meteor Shower")
	add_mana(0, Mtg.ManaColor.R)
	add_mana(0, Mtg.ManaColor.C, 4)
	assert_eq(pilot()._try_cast_best(g), "cast Meteor Shower")
	assert_false(g.stack.back().targets[0].is_player, "Glacial Chasm prevents the supposed lethal")
	resolve_stack()
	assert_eq(wall.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[1].life, 1)

func test_ai_covenant_does_not_pay_life_into_energy_storm() -> void:
	put_battlefield(1, "Serra Angel")
	put_battlefield(1, "Energy Storm")
	advance_to_step(Mtg.Step.MAIN1)
	var spell := give_hand(0, "Fire Covenant")
	add_mana(0, Mtg.ManaColor.B)
	add_mana(0, Mtg.ManaColor.R)
	add_mana(0, Mtg.ManaColor.C)
	var ai := pilot()
	ai.profile.holds_instants = false
	assert_true(ai._plan_spell_choice(g, spell, 0).is_empty(), "all spell damage is prevented")
	assert_eq(ai._try_cast_best(g), "", "all spell damage is prevented")
	assert_eq(spell.zone, Mtg.Zone.HAND)
	assert_eq(g.players[0].life, 20)
	assert_eq(g.players[0].mana_pool.total(), 3)

func test_combat_history_undo_and_cleanup() -> void:
	var attacker := put_battlefield(0, "Scaled Wurm")
	var blocker := put_battlefield(1, "Wall of Stone")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	var mark := g.make_mark()
	assert_ok(g.declare_blockers(1, {blocker.id: attacker.id}))
	assert_eq(g.combat_pair_history.size(), 1)
	g.unmake_to(mark)
	g.end_search()
	assert_true(g.combat_pair_history.is_empty())
	assert_true(g.awaiting_blockers)
	assert_ok(g.declare_blockers(1, {blocker.id: attacker.id}))
	assert_eq(g.combat_pair_history.size(), 1)
	advance_to_next_turn()
	assert_true(g.combat_pair_history.is_empty())

func test_same_combat_regressions_in_fifth_edition() -> void:
	for regression in [test_breath_does_not_destroy_attacker_returned_before_cast_on_blocker,
			test_battle_cry_trigger_does_not_pump_a_returned_blocker,
			test_breath_cast_before_blocks_remembers_a_marked_creature_that_died]:
		before_each()
		g.rules.set_edition("fifth")
		regression.call()

func test_deflection_forecast_null_retains_original_ranking() -> void:
	var colossus := put_battlefield(1, "Colossus of Sardia")
	advance_to_step(Mtg.Step.MAIN1)
	g.players[1].life = 3
	incoming_bolt()
	var ai := pilot()
	ai.profile.forecasts_tactics = false
	assert_eq(ai._respond_action(g), "cast Deflection")
	resolve_stack()
	assert_false(g.game_over)
	assert_eq(colossus.damage, 3)

func test_meteor_sizes_through_a_finite_shield_and_preserves_null() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	g.players[1].life = 1
	g.players[1].damage_prevention = 2
	var spell := give_hand(0, "Meteor Shower")
	var ai := pilot()
	# _plan_spell_choice also checks payment; use the decision seam here
	# and execute that exact proposed cast with real mana below.
	var corrected: Dictionary = load("res://engine/ai/ice_age_tactics.gd").spell_choice(g, ai, spell, 2, 0)
	assert_eq(corrected.x, 2)
	assert_eq(corrected.targets[0].amount, 3)
	ai.profile.forecasts_tactics = false
	var legacy: Dictionary = load("res://engine/ai/ice_age_tactics.gd").spell_choice(g, ai, spell, 2, 0)
	assert_eq(legacy.x, 0)
	add_mana(0, Mtg.ManaColor.R)
	add_mana(0, Mtg.ManaColor.C, 4)
	assert_ok(g.cast_spell(0, spell, corrected.targets, corrected.x))
	resolve_stack()
	assert_true(g.game_over)
	assert_eq(g.winner, 0)

func test_damage_ranking_is_hidden_invariant_and_does_not_consume_state() -> void:
	var colossus := put_battlefield(1, "Colossus of Sardia")
	advance_to_step(Mtg.Step.MAIN1)
	g.players[1].life = 3
	var bolt := incoming_bolt()
	var hidden := give_hand(1, "Island")
	var ai := pilot()
	var helper = load("res://engine/ai/ice_age_tactics.gd")
	var rng_before := g.rng.state
	var choices_before := g.choice_log.size()
	var value: float = helper.retarget_value(g, ai, bolt, TargetRef.player(1))
	for name in ["Counterspell", "Healing Salve", "Forest"]:
		hidden.data = CardRegistry.get_card(name)
		g.players[0].library[0].data = CardRegistry.get_card(name)
		g.players[1].library[0].data = CardRegistry.get_card(name)
		g.players[0].library.reverse()
		g.players[1].library.reverse()
		assert_eq(helper.retarget_value(g, ai, bolt, TargetRef.player(1)), value)
	assert_eq(g.rng.state, rng_before)
	assert_eq(g.choice_log.size(), choices_before)
	assert_eq(colossus.damage, 0)
	g.players[1].damage_prevention = 3
	assert_eq(helper.retarget_value(g, ai, bolt, TargetRef.player(1)), 0.0, "public shield changes the decision")
	assert_eq(g.players[1].damage_prevention, 3, "the forecast must not consume it")

func test_retarget_estimate_reads_lava_burst_creature_only_exception() -> void:
	var wall := put_battlefield(1, "Wall of Wood")
	put_battlefield(0, "Energy Storm")
	advance_to_step(Mtg.Step.MAIN1)
	var lava := give_hand(1, "Lava Burst")
	g.active_player = 1
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.R, 4)
	assert_ok(g.cast_spell(1, lava, [TargetRef.player(0)], 3))
	var ai := pilot()
	var helper = load("res://engine/ai/ice_age_tactics.gd")
	assert_gt(helper.retarget_value(g, ai, lava, TargetRef.card(wall)), 0.0)
	assert_eq(helper.retarget_value(g, ai, lava, TargetRef.player(1)), 0.0)

func test_ai_breath_marks_its_own_attacker_to_destroy_the_enemy_blocker() -> void:
	var attacker := put_battlefield(0, "Grizzly Bears")
	var blocker := put_battlefield(1, "Scaled Wurm")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {blocker.id: attacker.id}))
	give_hand(0, "Venomous Breath")
	add_mana(0, Mtg.ManaColor.G, 4)
	assert_eq(pilot()._respond_action(g), "cast Venomous Breath")
	if g.stack.is_empty():
		fail_test("the AI never offered its combat removal")
		return
	assert_eq(g.stack.back().targets[0].instance_id, attacker.id)
	resolve_stack()
	advance_to_step(Mtg.Step.COMBAT_END)
	resolve_stack()
	assert_eq(blocker.zone, Mtg.Zone.GRAVEYARD)

func test_ai_does_not_waste_breath_before_any_creatures_fought() -> void:
	put_battlefield(1, "Scaled Wurm")
	advance_to_step(Mtg.Step.MAIN1)
	var spell := give_hand(0, "Venomous Breath")
	add_mana(0, Mtg.ManaColor.G, 4)
	assert_eq(pilot()._try_cast_best(g), "")
	assert_eq(spell.zone, Mtg.Zone.HAND)

func test_ai_battle_cry_untaps_a_white_blocker_against_lethal() -> void:
	var blocker := put_battlefield(0, "Serra Angel")
	var attacker := put_battlefield(1, "Scaled Wurm")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	g.active_player = 1
	g.priority_player = 1
	g.players[0].life = 2
	g.tap_permanent(blocker)
	assert_ok(g.declare_attackers(1, [attacker.id]))
	g.priority_player = 0
	give_hand(0, "Battle Cry")
	add_mana(0, Mtg.ManaColor.W, 3)
	assert_eq(pilot()._respond_action(g), "cast Battle Cry")
	resolve_stack()
	assert_false(blocker.tapped)

func test_ai_does_not_waste_battle_cry_on_an_untapped_board() -> void:
	put_battlefield(0, "Serra Angel")
	advance_to_step(Mtg.Step.MAIN1)
	var spell := give_hand(0, "Battle Cry")
	add_mana(0, Mtg.ManaColor.W, 3)
	assert_eq(pilot()._try_cast_best(g), "")
	assert_eq(spell.zone, Mtg.Zone.HAND)

func test_battle_cry_forecast_is_pure_hidden_invariant_and_null_gated() -> void:
	var blocker := put_battlefield(0, "Serra Angel")
	var attacker := put_battlefield(1, "Scaled Wurm")
	var hidden := give_hand(1, "Island")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	g.active_player = 1
	g.priority_player = 1
	g.players[0].life = 2
	g.tap_permanent(blocker)
	assert_ok(g.declare_attackers(1, [attacker.id]))
	var spell := give_hand(0, "Battle Cry")
	var ai := pilot()
	var helper = load("res://engine/ai/ice_age_tactics.gd")
	var rng_before := g.rng.state
	var log_before := g.log_lines.size()
	var life_before := g.players[0].life
	var choice: Dictionary = helper.combat_spell_choice(g, ai, spell)
	assert_eq(choice.value, AiPlayer.LETHAL_WORTH)
	for name in ["Counterspell", "Terror", "Forest"]:
		hidden.data = CardRegistry.get_card(name)
		g.players[0].library[0].data = CardRegistry.get_card(name)
		g.players[1].library[0].data = CardRegistry.get_card(name)
		assert_eq(helper.combat_spell_choice(g, ai, spell).value, choice.value)
	assert_true(blocker.tapped)
	assert_eq(blocker.cur_toughness, 4)
	assert_eq(g.rng.state, rng_before)
	assert_eq(g.log_lines.size(), log_before)
	assert_eq(g.players[0].life, life_before)
	assert_null(g.undo_log)
	ai.profile.forecasts_tactics = false
	assert_null(helper.spell_choice(g, ai, spell, 0, 0))
	g.grant_keyword_permanently(attacker, Mtg.Keyword.UNBLOCKABLE)
	assert_true(helper.combat_spell_choice(g, ai, spell).is_empty(), "public evasion removes the rescue")

func test_breath_waits_when_combat_already_kills_the_only_victim() -> void:
	var pair := combat_pair()
	var spell := give_hand(0, "Venomous Breath")
	g.deal_damage(pair[0], TargetRef.card(pair[1]), 1)
	# The 7/6 Wurm kills this already-damaged 0/8 Wall.
	var choice: Dictionary = load("res://engine/ai/ice_age_tactics.gd").combat_spell_choice(g, pilot(), spell)
	assert_true(choice.is_empty())
	assert_eq(pair[1].zone, Mtg.Zone.BATTLEFIELD, "forecast must leave the actual combat unresolved")

func test_ai_does_not_buy_the_same_delayed_breath_kill_twice() -> void:
	var attacker := put_battlefield(0, "Grizzly Bears")
	var blocker := put_battlefield(1, "Scaled Wurm")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {blocker.id: attacker.id}))
	give_hand(0, "Venomous Breath")
	give_hand(0, "Venomous Breath")
	add_mana(0, Mtg.ManaColor.G, 8)
	var ai := pilot()
	assert_eq(ai._respond_action(g), "cast Venomous Breath")
	resolve_stack()
	assert_eq(ai._respond_action(g), "", "the existing delayed effect already covers this survivor")
	assert_eq(g.players[0].mana_pool.total(), 4)
	assert_eq(g.players[0].hand.size(), 1)

func cry_combat(attacker_name: String) -> CardInstance:
	var blocker := put_battlefield(0, "Shield Bearer")
	var attacker := put_battlefield(1, attacker_name)
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	g.active_player = 1
	g.priority_player = 1
	assert_ok(g.declare_attackers(1, [attacker.id]))
	g.priority_player = 0
	return blocker

func test_ai_does_not_repeat_a_battle_cry_that_already_saves_its_blocker() -> void:
	var blocker := cry_combat("Hill Giant")
	give_hand(0, "Battle Cry")
	give_hand(0, "Battle Cry")
	add_mana(0, Mtg.ManaColor.W, 6)
	var ai := pilot()
	assert_eq(ai._respond_action(g), "cast Battle Cry")
	resolve_stack()
	assert_eq(blocker.cur_toughness, 3, "bonus is still pending until blocks")
	assert_ok(g.pass_priority(1))
	assert_eq(ai._respond_action(g), "")
	assert_eq(g.players[0].mana_pool.total(), 3)
	assert_eq(g.players[0].hand.size(), 1)

func test_ai_can_add_a_second_battle_cry_when_two_bonuses_are_needed() -> void:
	cry_combat("Serra Angel")
	# Give the blocking creature flying as setup so legality is not the
	# reason to refuse. The 0/3 needs BOTH +0/+1 bonuses against a 4/4.
	var blocker := g.find_on_battlefield(0, "Shield Bearer")
	g.grant_keyword_permanently(blocker, Mtg.Keyword.FLYING)
	var first := give_hand(0, "Battle Cry")
	give_hand(0, "Battle Cry")
	add_mana(0, Mtg.ManaColor.W, 6)
	assert_ok(g.cast_spell(0, first))
	resolve_stack()
	assert_ok(g.pass_priority(1))
	assert_eq(pilot()._respond_action(g), "cast Battle Cry")
