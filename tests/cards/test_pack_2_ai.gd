extends GameTest
## Real activation decisions, including their costs, targets and resolution.

func before_each() -> void:
	CardPacks.set_enabled(FallenEmpiresPack.ID, true)
	super()

func after_each() -> void:
	g = null
	CardPacks.set_enabled(FallenEmpiresPack.ID, false)
	CardPacks.set_enabled(CardPacks.ID, false)

func pilot() -> AiPlayer:
	var ai := AiPlayer.new(0, AiProfile.wizard())
	ai.profile.develops_late = false
	g.agents[0] = ai
	return ai

func test_ai_seasinger_steals_an_enemy_not_its_own_creature() -> void:
	put_battlefield(0, "Island")
	put_battlefield(1, "Island")
	var singer := put_battlefield(0, "Seasinger")
	var enemy := put_battlefield(1, "Craw Wurm")
	put_battlefield(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	assert_eq(pilot()._try_activate(g), "activated Seasinger")
	assert_eq(g.stack.back().targets[0].instance_id, enemy.id)
	resolve_stack()
	assert_eq(enemy.controller_id, 0)
	assert_true(singer.tapped)
	assert_true(pilot()._ability_option(g, singer, 0, AiPlayer.Moment.MAIN).is_empty())

func test_ai_completes_a_spore_cycle_and_makes_a_token() -> void:
	var thallid := put_battlefield(0, "Thallid")
	put_battlefield(0, "Fungal Bloom")
	g.add_counters(thallid, "spore", 2)
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.G, 2)
	var ai := pilot()
	assert_eq(ai._try_activate(g), "activated Fungal Bloom")
	resolve_stack()
	assert_eq(int(thallid.counters.get("spore", 0)), 3)
	assert_eq(ai._try_activate(g, AiPlayer.Moment.SINK), "activated Thallid")
	resolve_stack()
	assert_eq(g.players[0].battlefield.size(), 3)
	assert_eq(int(thallid.counters.get("spore", 0)), 0)

func test_ai_can_remove_nets_from_an_opponents_merseine() -> void:
	var host := put_battlefield(0, "Ornithopter")
	var net := give_hand(1, "Merseine")
	advance_to_step(Mtg.Step.MAIN1)
	g.active_player = 1
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.U, 4)
	assert_ok(g.cast_spell(1, net, [TargetRef.card(host)]))
	resolve_stack()
	g.tap_permanent(host)
	g.active_player = 0
	g.priority_player = 0
	var ai := pilot()
	for _i in 3:
		assert_eq(ai._try_activate(g, AiPlayer.Moment.SINK), "activated Merseine")
		resolve_stack()
	assert_false(host.cur_skips_untap)
	assert_eq(ai._try_activate(g, AiPlayer.Moment.SINK), "", "zero-cost escape stops when nets run out")

func test_ai_freezes_a_tapped_threat_and_does_not_refresh_the_same_lock() -> void:
	var hunter := put_battlefield(0, "Elvish Hunter")
	var enemy := put_battlefield(1, "Craw Wurm")
	g.tap_permanent(enemy)
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.G, 2)
	var ai := pilot()
	assert_eq(ai._try_activate(g), "activated Elvish Hunter")
	resolve_stack()
	assert_true(enemy.skip_next_untap)
	assert_true(ai._ability_option(g, hunter, 0, AiPlayer.Moment.SINK).is_empty())

func test_ai_uses_shroud_only_in_response_to_a_hostile_target() -> void:
	var spawn := put_battlefield(0, "Deep Spawn")
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.U)
	var ai := pilot()
	assert_eq(ai._try_activate(g), "")
	var sword := give_hand(1, "Swords to Plowshares")
	add_mana(1, Mtg.ManaColor.W)
	g.priority_player = 1
	assert_ok(g.cast_spell(1, sword, [TargetRef.card(spawn)]))
	g.priority_player = 0
	assert_eq(ai._respond_action(g), "activated Deep Spawn")
	resolve_stack()
	assert_eq(spawn.zone, Mtg.Zone.BATTLEFIELD)
	assert_true(spawn.cur_shroud)
	assert_true(spawn.tapped and spawn.skip_next_untap)

func test_ai_prepares_the_war_machine_with_a_merfolk_crew() -> void:
	var machine := put_battlefield(0, "Vodalian War Machine")
	var crew := put_battlefield(0, "Merfolk of the Pearl Trident")
	put_battlefield(0, "Merfolk of the Pearl Trident")
	advance_to_step(Mtg.Step.MAIN1)
	var ai := pilot()
	assert_eq(ai._try_activate(g), "activated Vodalian War Machine")
	assert_true(crew.tapped)
	resolve_stack()
	assert_true(machine.cur_can_attack_with_defender)
	assert_eq(ai._try_activate(g), "activated Vodalian War Machine", "a second crew member powers its attack")
	resolve_stack()
	assert_eq(machine.cur_power, 2)
	assert_eq(ai._try_activate(g), "", "does not pay twice for permission")

func test_ai_uses_a_tax_counter_only_when_public_mana_cannot_pay() -> void:
	var mage := put_battlefield(0, "Vodalian Mage")
	var worm := give_hand(1, "Craw Wurm")
	advance_to_step(Mtg.Step.MAIN1)
	g.active_player = 1
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.G, 6)
	assert_ok(g.cast_spell(1, worm))
	g.priority_player = 0
	add_mana(0, Mtg.ManaColor.U)
	var ai := pilot()
	ai.profile.counter_threshold = 1.0
	add_mana(1, Mtg.ManaColor.C)
	assert_eq(ai._try_activate(g, AiPlayer.Moment.RESPONSE), "")
	g.players[1].mana_pool.clear()
	assert_eq(ai._try_activate(g, AiPlayer.Moment.RESPONSE), "activated Vodalian Mage")
	assert_true(mage.tapped)
	resolve_stack()
	assert_eq(worm.zone, Mtg.Zone.GRAVEYARD)

func test_white_laces_cannot_bypass_raiding_partys_targeting_ban() -> void:
	var party := put_battlefield(0, "Raiding Party")
	var white := give_hand(1, "Purelace")
	var blue := give_hand(1, "Thoughtlace")
	var spec := TargetSpec.spell_or_permanent()
	assert_false(spec.is_legal(g, TargetRef.card(party), white))
	assert_true(spec.is_legal(g, TargetRef.card(party), blue))

func test_high_tide_unlocks_a_spell_and_planner_spends_the_bonus_mana() -> void:
	for _i in 4: put_battlefield(0, "Island")
	var tide := give_hand(0, "High Tide")
	var spawn := give_hand(0, "Deep Spawn")
	# Deep Spawn costs eight; five Islands would leave four after Tide.
	put_battlefield(0, "Island")
	advance_to_step(Mtg.Step.MAIN1)
	var ai := pilot()
	assert_false(ai.FALLEN_EMPIRES_TACTICS.high_tide_enables(g, ai, tide, []))
	assert_true(ai.FALLEN_EMPIRES_TACTICS.high_tide_enables(g, ai, tide, ManaPlanner.sources(g, 0)))
	assert_true(ManaPlanner.plan(g, 0, spawn.data.cost, 0).is_empty())
	assert_true(ManaPlanner.plan_and_pay(g, 0, tide.data.cost))
	assert_ok(g.cast_spell(0, tide))
	resolve_stack()
	assert_false(ManaPlanner.plan(g, 0, spawn.data.cost, 0).is_empty())
	assert_true(ManaPlanner.plan_and_pay(g, 0, spawn.data.cost))
	assert_ok(g.cast_spell(0, spawn))
	resolve_stack()
	assert_eq(spawn.zone, Mtg.Zone.BATTLEFIELD)

func test_ai_does_not_waste_high_tide_with_no_payoff_in_hand() -> void:
	for _i in 5: put_battlefield(0, "Island")
	var tide := give_hand(0, "High Tide")
	advance_to_step(Mtg.Step.MAIN1)
	var ai := pilot()
	assert_false(ai.FALLEN_EMPIRES_TACTICS.high_tide_enables(g, ai, tide, ManaPlanner.sources(g, 0)))
	assert_eq(ai._try_cast_best(g), "")
	assert_eq(tide.zone, Mtg.Zone.HAND)

func test_control_ability_does_not_outlive_control_of_its_source() -> void:
	put_battlefield(0, "Island")
	put_battlefield(1, "Island")
	var singer := put_battlefield(0, "Seasinger")
	var victim := put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	assert_ok(g.activate_ability(0, singer, 0, [TargetRef.card(victim)]))
	g.change_control(singer, 1)
	resolve_stack()
	assert_eq(victim.controller_id, 1)
	assert_eq(victim.controlled_via, -1)

func test_ai_goblin_chirurgeon_can_pay_a_cheap_goblin_to_save_a_threat() -> void:
	put_battlefield(0, "Goblin Chirurgeon")
	put_battlefield(0, "Mons's Goblin Raiders")
	var victim := put_battlefield(0, "Craw Wurm")
	advance_to_step(Mtg.Step.MAIN1)
	assert_eq(pilot()._shield(g, victim), "shields Craw Wurm")
	resolve_stack()
	assert_eq(victim.regeneration_shields, 1)
	assert_eq(g.players[0].graveyard.size(), 1)

func test_catapult_chooses_the_smallest_x_that_kills_the_creature_group() -> void:
	var spell := give_hand(0, "Dwarven Catapult")
	var one := put_battlefield(1, "Grizzly Bears")
	var two := put_battlefield(1, "Grizzly Bears")
	var ai := pilot()
	var choice := ai.FALLEN_EMPIRES_TACTICS.catapult_choice(g, ai, spell, 8)
	assert_eq(choice.get("x"), 4, "four divided by two is two damage each; no wasted X")
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.R, 5)
	assert_ok(g.cast_spell(0, spell, choice.targets, choice.x))
	resolve_stack()
	assert_eq(one.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(two.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[1].life, 20, "the player is the target, not the damage recipient")
	assert_true(ai.FALLEN_EMPIRES_TACTICS.catapult_choice(g, ai, spell, 8).is_empty())

func test_ai_fogs_with_spore_counters_when_the_attack_is_lethal() -> void:
	var flower := put_battlefield(0, "Spore Flower")
	var attacker := put_battlefield(1, "Craw Wurm")
	g.add_counters(flower, "spore", 3)
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	g.active_player = 1
	g.priority_player = 1
	g.players[0].life = 5
	assert_ok(g.declare_attackers(1, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(0, {}))
	g.priority_player = 0
	assert_eq(pilot()._try_activate(g, AiPlayer.Moment.RESPONSE), "activated Spore Flower")
	resolve_stack()
	assert_true(g.combat_damage_prevented)
	assert_eq(int(flower.counters.get("spore", 0)), 0)

func test_ai_can_discard_for_a_permanent_counter_but_prices_the_lost_card() -> void:
	var armorer := put_battlefield(0, "Dwarven Armorer")
	put_battlefield(0, "Craw Wurm")
	advance_to_step(Mtg.Step.MAIN1)
	var ai := pilot()
	assert_false(ai._ability_available(g, armorer, 0, true))
	give_hand(0, "Forest")
	assert_true(ai._ability_available(g, armorer, 0, true))
	var cheap := ai._discard_price(g, armorer.cur_activated_abilities[0])
	give_hand(0, "Craw Wurm")
	assert_eq(ai._discard_price(g, armorer.cur_activated_abilities[0]), cheap)
	var random := ActivatedAbility.new("", false, [])
	random.random_discard_cost = 1
	var rng_before := g.rng.state
	assert_gt(ai._discard_price(g, random), cheap)
	assert_eq(g.rng.state, rng_before, "random discard is an expectation, not a peek")

func test_ai_does_not_save_the_opponents_plains_with_raiding_party() -> void:
	var theirs := put_battlefield(1, "Plains")
	var list: Array[CardInstance] = [theirs]
	assert_null(pilot().answer_card(g, 0, list, "Choose a Plains to save"))

func test_control_activation_cannot_attach_to_a_reentered_source() -> void:
	var champion := put_battlefield(0, "Thrull Champion")
	var victim := put_battlefield(1, "Basal Thrull")
	advance_to_step(Mtg.Step.MAIN1)
	assert_ok(g.activate_ability(0, champion, 0, [TargetRef.card(victim)]))
	g.return_to_hand(champion)
	g._put_on_battlefield(champion, 0)
	resolve_stack()
	assert_eq(victim.controller_id, 1)
	assert_eq(victim.controlled_via, -1)

func test_farrels_mantle_trigger_remembers_its_attacker_after_aura_leaves() -> void:
	var attacker := put_battlefield(0, "Grizzly Bears")
	var victim := put_battlefield(1, "Giant Spider")
	var mantle := give_hand(0, "Farrel's Mantle")
	g.attach_aura_from_anywhere(mantle, attacker, 0)
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {}))
	assert_false(g.stack.is_empty())
	g.destroy(mantle)
	resolve_stack()
	assert_eq(victim.zone, Mtg.Zone.GRAVEYARD)
	assert_true(attacker.cur_assigns_no_combat_damage)

func test_farrels_mantle_uses_last_power_if_the_attacker_leaves() -> void:
	var attacker := put_battlefield(0, "Grizzly Bears")
	var victim := put_battlefield(1, "Craw Wurm")
	var mantle := give_hand(0, "Farrel's Mantle")
	g.attach_aura_from_anywhere(mantle, attacker, 0)
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {}))
	g.continuous.add_until_eot_pump(attacker.id, 2, 2)
	g.recalculate()
	g.return_to_hand(attacker)
	resolve_stack()
	assert_eq(victim.zone, Mtg.Zone.GRAVEYARD, "last power four plus two still deals six")

func test_mindstab_cannot_sacrifice_a_new_incarnation_for_an_old_trigger() -> void:
	var thrull := put_battlefield(0, "Mindstab Thrull")
	for _i in 3: give_hand(1, "Forest")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [thrull.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {}))
	g.return_to_hand(thrull)
	g._put_on_battlefield(thrull, 0)
	resolve_stack()
	assert_eq(thrull.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(g.players[1].hand.size(), 3)

func test_heroism_does_not_sacrifice_again_for_an_already_prevented_attacker() -> void:
	var heroism := put_battlefield(0, "Heroism")
	put_battlefield(0, "Savannah Lions")
	var attacker := put_battlefield(1, "Shivan Dragon")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	g.active_player = 1
	g.priority_player = 1
	assert_ok(g.declare_attackers(1, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(0, {}))
	g.continuous.add_until_eot_combat_prevention(attacker.id, true, false)
	g.recalculate()
	assert_true(pilot()._ability_option(g, heroism, 0, AiPlayer.Moment.RESPONSE).is_empty())
