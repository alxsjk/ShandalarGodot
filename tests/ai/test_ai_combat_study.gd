extends GameTest


func _pilot(seat := 0) -> AiPlayer:
	var profile := AiProfile.wizard()
	profile.studies_combat = true
	var pilot := AiPlayer.new(seat, profile)
	g.set_agent(seat, pilot)
	return pilot


func test_forward_combat_prices_a_gang_as_one_complete_exchange() -> void:
	var pilot := _pilot()
	var attacker := put_battlefield(0, "Craw Wurm")
	var first := put_battlefield(1, "Grizzly Bears")
	var second := put_battlefield(1, "Grizzly Bears")
	var ours: Array[CardInstance] = [attacker]
	var theirs: Array[CardInstance] = [first, second]
	var result := pilot._studied_exchange(g, ours, theirs, 1)
	assert_eq(result["blocks"].size(), 2)
	assert_eq(result["attacker_dead"], 1)
	assert_eq(result["damage"], 0)
	assert_lt(float(result["value"]), 0.0)
	assert_eq(pilot._cohort_value(g, ours, theirs, 1), result["value"])
	assert_eq(pilot._damage_through_blocks(g, ours, theirs, 1), result["damage"])


func test_study_selects_joint_blocks_and_never_spends_a_body_twice() -> void:
	var pilot := _pilot(1)
	var attacker := put_battlefield(0, "Craw Wurm")
	var first := put_battlefield(1, "Grizzly Bears")
	var second := put_battlefield(1, "Grizzly Bears")
	var attackers: Array[CardInstance] = [attacker]
	var blockers: Array[CardInstance] = [first, second]
	var used: Array[int] = []
	var mapping := pilot._block_choice(g, attackers, blockers, used)
	assert_eq(mapping, {first.id: attacker.id, second.id: attacker.id})
	assert_eq(used.size(), 2)
	assert_lte(pilot.last_combat_nodes, pilot.profile.combat_search_nodes)


func test_mini_study_keeps_the_defence_that_stops_a_lethal_counterattack() -> void:
	var pilot := _pilot()
	var first := put_battlefield(0, "Grizzly Bears")
	var second := put_battlefield(0, "Grizzly Bears")
	var wurm := put_battlefield(1, "Craw Wurm")
	wurm.tapped = true
	g.adjust_life(0, -15)
	var candidates: Array[CardInstance] = [first, second]
	var result := pilot._studied_attack(g, candidates, 1)
	assert_eq(result["attackers"], [])
	assert_lte(pilot.last_combat_nodes, pilot.profile.combat_search_nodes)


func test_new_combat_search_is_invariant_under_hidden_card_substitution() -> void:
	var pilot := _pilot()
	var first := put_battlefield(0, "Hill Giant")
	put_battlefield(1, "Grizzly Bears")
	var hidden := give_hand(1, "Giant Growth")
	var candidates: Array[CardInstance] = [first]
	var initial := pilot._studied_attack(g, candidates, 1)
	var state := g.rng.state
	hidden.data = CardRegistry.get_card("Terror")
	g.players[1].library.reverse()
	assert_eq(pilot._studied_attack(g, candidates, 1), initial)
	assert_eq(g.rng.state, state)
	assert_false(first.tapped)


func test_own_hand_trick_changes_the_exchange_but_is_not_spent_during_study() -> void:
	var pilot := _pilot()
	var bear := put_battlefield(0, "Grizzly Bears")
	var giant := put_battlefield(1, "Hill Giant")
	var forest := put_battlefield(0, "Forest")
	var ours: Array[CardInstance] = [bear]
	var theirs: Array[CardInstance] = [giant]
	var without := pilot._studied_exchange(g, ours, theirs, 1)
	var trick := give_hand(0, "Giant Growth")
	var state := g.rng.state
	var with_trick := pilot._studied_exchange(g, ours, theirs, 1)
	assert_gt(float(with_trick["value"]), float(without["value"]))
	assert_eq(bear.cur_power, 2)
	assert_eq(bear.cur_toughness, 2)
	assert_true(g.players[0].hand.has(trick))
	assert_false(forest.tapped)
	assert_eq(g.rng.state, state)
	assert_null(g.undo_log)
	forest.tapped = true
	assert_eq(pilot._studied_exchange(g, ours, theirs, 1), without,
		"an unaffordable trick contributes nothing")


func test_one_pump_cannot_save_two_simultaneous_blocks() -> void:
	var pilot := _pilot(1)
	var giant := put_battlefield(0, "Hill Giant")
	var other_giant := put_battlefield(0, "Hill Giant")
	var bear := put_battlefield(1, "Grizzly Bears")
	var other_bear := put_battlefield(1, "Grizzly Bears")
	put_battlefield(1, "Forest")
	give_hand(1, "Giant Growth")
	var mine: Array[CardInstance] = [bear, other_bear]
	var theirs: Array[CardInstance] = [giant, other_giant]
	var model := pilot._build_combat_model(g, mine, theirs, [], 0)
	var study := AiCombatStudy.new(model)
	study.ours_attacks = false
	study.responses = pilot._study_responses(g, mine, theirs, [], 0, model)
	study._limit = 100
	var result := study._evaluate(3, {0: 0, 1: 1}, true)
	assert_true(result["attacker_dead"] == 1 or result["attacker_dead"] == 2)
	assert_true(result["defender_dead"] == 1 or result["defender_dead"] == 2)
	assert_eq(result["damage"], 0)


func test_public_pump_and_own_booked_mana_keep_the_specialised_policy() -> void:
	var pilot := _pilot()
	var giant := put_battlefield(0, "Hill Giant")
	var shade := put_battlefield(1, "Frozen Shade")
	put_battlefield(1, "Swamp")
	var ours: Array[CardInstance] = [giant]
	var theirs: Array[CardInstance] = [shade]
	assert_false(pilot._study_supported(g, ours, theirs, 1))
	pilot._pump_plan_turn = g.turn_number
	pilot._pump_plan = {giant.id: 1}
	assert_false(pilot._study_supported(g, ours, [], 1))


func test_first_strike_and_trample_use_the_shared_combat_resolver() -> void:
	var pilot := _pilot()
	var knight := put_battlefield(0, "White Knight")
	var bear := put_battlefield(1, "Grizzly Bears")
	var ours: Array[CardInstance] = [knight]
	var theirs: Array[CardInstance] = [bear]
	var model := pilot._build_combat_model(g, ours, theirs, ours, 1)
	var study := AiCombatStudy.new(model)
	assert_eq(study._exchange_result(1, {0: 0})["attacker_dead"], 0)
	assert_eq(study._exchange_result(1, {0: 0})["defender_dead"], 1)
	var force := put_battlefield(0, "Force of Nature")
	ours.assign([force])
	study = AiCombatStudy.new(pilot._build_combat_model(g, ours, theirs, ours, 1))
	assert_eq(study._exchange_result(1, {0: 0})["damage"], 6)
	study.budget = 3
	study.best_attack()
	assert_lte(study.nodes, 3)


func test_whole_assignment_preserves_the_wurm_and_kills_the_smaller_attacker() -> void:
	var pilot := _pilot(1)
	g.players[1].life = 12
	var wurm := put_battlefield(1, "Craw Wurm")
	var elves := put_battlefield(1, "Llanowar Elves")
	var enemy_wurm := put_battlefield(0, "Craw Wurm")
	var enemy_bear := put_battlefield(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [enemy_wurm.id, enemy_bear.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_string_contains(pilot.act(g), "declared 2 block")
	assert_eq(g.combat.blocks.get(wurm.id), enemy_bear.id)
	assert_eq(g.combat.blocks.get(elves.id), enemy_wurm.id)
	advance_to_step(Mtg.Step.MAIN2)
	assert_eq(wurm.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(enemy_bear.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(elves.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[1].life, 12)


func test_wide_study_has_a_hard_budget_and_an_explicit_size_fallback() -> void:
	var pilot := _pilot()
	pilot.profile.combat_search_nodes = 80
	var mine: Array[CardInstance] = []
	for _i in 12:
		mine.append(put_battlefield(0, "Grizzly Bears"))
		put_battlefield(1, "Grizzly Bears")
	var state := g.rng.state
	var first := pilot._studied_attack(g, mine, 1)
	assert_false(first.is_empty())
	assert_lte(pilot.last_combat_nodes, 80)
	assert_eq(pilot._studied_attack(g, mine, 1), first)
	assert_eq(g.rng.state, state)
	mine.append(put_battlefield(0, "Grizzly Bears"))
	assert_eq(pilot._studied_attack(g, mine, 1), {})
	assert_eq(pilot.last_combat_nodes, 0)


func test_reverse_damage_query_keeps_the_known_trick_on_its_owners_side() -> void:
	var pilot := _pilot()
	var bear := put_battlefield(0, "Grizzly Bears")
	put_battlefield(0, "Forest")
	var giant := put_battlefield(1, "Hill Giant")
	var attackers: Array[CardInstance] = [giant]
	var blockers: Array[CardInstance] = [bear]
	var before := pilot._studied_exchange(g, attackers, blockers, 0)
	assert_eq(before["damage"], 3)
	give_hand(0, "Giant Growth")
	var after := pilot._studied_exchange(g, attackers, blockers, 0)
	assert_eq(after["damage"], 0)
	assert_eq(after["attacker_dead"], 1, "our trick protects our blocker")
	assert_eq(after["defender_dead"], 0)
	assert_eq(bear.cur_power, 2)
	assert_eq(giant.cur_power, 3)
