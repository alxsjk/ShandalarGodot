extends GameTest


func test_observation_excludes_hidden_hands_decklists_libraries_and_rng() -> void:
	put_battlefield(0, "Hill Giant")
	put_battlefield(1, "Grizzly Bears")
	give_hand(0, "Lightning Bolt")
	var hidden := give_hand(1, "Giant Growth")
	var before := AiObservation.key(g, 0)
	hidden.data = CardRegistry.get_card("Shivan Dragon")
	g.players[1].deck_names.assign(["Shivan Dragon"])
	g.players[0].library.reverse()
	g.players[1].library.reverse()
	g.rng.randf()
	assert_eq(AiObservation.key(g, 0), before)
	assert_false(before.contains("Giant Growth"))
	assert_false(before.contains("Shivan Dragon"))
	assert_true(before.contains("Lightning Bolt"))


func test_reveal_and_public_changes_invalidate_observation() -> void:
	var card := give_hand(1, "Giant Growth")
	var before := AiObservation.key(g, 0)
	card.revealed_in_hand = true
	var revealed := AiObservation.key(g, 0)
	assert_ne(before, revealed)
	assert_true(revealed.contains("Giant Growth"))
	g.adjust_life(1, -1)
	assert_ne(revealed, AiObservation.key(g, 0))


func test_unknown_face_down_identity_is_not_in_observation() -> void:
	var card := put_battlefield(1, "Grizzly Bears")
	card.face_down = true
	var before := AiObservation.key(g, 0)
	card.data = CardRegistry.get_card("Shivan Dragon")
	assert_eq(before, AiObservation.key(g, 0))


func test_action_search_prefers_two_useful_casts_over_one_ranked_creature() -> void:
	var planner := AiActionPlanner.new()
	var options := [{"id": 1, "value": 8.0, "cost": 4, "independent": true},
		{"id": 2, "value": 5.0, "cost": 2, "independent": true},
		{"id": 3, "value": 4.0, "cost": 2, "independent": true}]
	var line := planner.choose(options, func(cards: Array) -> bool:
		var cost := 0
		for card in cards: cost += int(card["cost"])
		return cost <= 4)
	assert_eq(line.size(), 2)
	assert_eq(line[0]["id"], 2)
	assert_eq(line[1]["id"], 3)
	assert_lte(planner.nodes, planner.budget)


func test_uncertain_draws_end_a_line_and_budget_is_hard() -> void:
	var planner := AiActionPlanner.new()
	planner.budget = 2
	var options := [{"id": 1, "value": 8.0, "independent": false},
		{"id": 2, "value": 2.0, "independent": true}]
	var line := planner.choose(options, func(_cards: Array) -> bool: return true)
	assert_eq(line.size(), 1)
	assert_eq(line[0]["id"], 1)
	assert_lte(planner.nodes, 2)


func test_real_casts_follow_a_shared_mana_plan() -> void:
	var profile := AiProfile.wizard()
	profile.action_search_nodes = 96
	var pilot := AiPlayer.new(0, profile)
	g.set_agent(0, pilot)
	for _i in 4: put_battlefield(0, "Forest")
	give_hand(0, "Giant Spider")
	give_hand(0, "Grizzly Bears")
	give_hand(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	assert_string_contains(pilot.act(g), "Grizzly Bears")
	assert_gt(pilot.last_action_nodes, 0)
	resolve_stack()
	assert_string_contains(pilot.act(g), "Grizzly Bears")
	assert_eq(pilot.last_action_nodes, 0, "the second independently legal cast reuses the plan")
	resolve_stack()
	assert_not_null(g.find_in_hand(0, "Giant Spider"))
	assert_eq(g.players[0].battlefield.filter(func(c: CardInstance) -> bool:
		return c.data.card_name == "Grizzly Bears").size(), 2)


func test_deck_study_uses_own_registered_list_before_drawing() -> void:
	var pilot := AiPlayer.new(0, AiProfile.wizard())
	g.players[0].deck_names.assign(["Channel", "Fireball", "Forest", "Mountain"])
	g.players[1].deck_names.assign(["Terror", "Swamp"])
	g.set_agent(0, pilot)
	assert_true(pilot.deck_study.counts.has("Channel"))
	assert_false(pilot.deck_study.counts.has("Terror"))
	assert_eq(g.players[0].hand.size(), 0)


func test_target_x_and_position_score_do_not_read_hidden_cards() -> void:
	var pilot := AiPlayer.new(0, AiProfile.wizard())
	g.set_agent(0, pilot)
	var fireball := give_hand(0, "Fireball")
	put_battlefield(1, "Hill Giant")
	var hidden := give_hand(1, "Giant Growth")
	var intent := EffectIntent.read(fireball.data.spell_effects, "Fireball")
	var before := pilot._size_and_aim(g, fireball, intent, 6, 0)
	var score := Evaluator.position_score(g, 0, pilot.profile)
	hidden.data = CardRegistry.get_card("Counterspell")
	g.players[1].deck_names.assign(["Counterspell", "Counterspell"])
	g.players[0].library.reverse()
	g.players[1].library.reverse()
	g.rng.randf()
	var after := pilot._size_and_aim(g, fireball, intent, 6, 0)
	assert_false(before.is_empty())
	assert_eq(after["x"], before["x"])
	assert_eq(after["value"], before["value"])
	assert_eq(after["targets"].size(), before["targets"].size())
	for i in before["targets"].size():
		assert_eq(after["targets"][i].instance_id, before["targets"][i].instance_id)
		assert_eq(after["targets"][i].player_id, before["targets"][i].player_id)
	assert_eq(Evaluator.position_score(g, 0, pilot.profile), score)


func test_public_change_invalidates_a_saved_action_line() -> void:
	var profile := AiProfile.wizard()
	profile.action_search_nodes = 96
	var pilot := AiPlayer.new(0, profile)
	g.set_agent(0, pilot)
	for _i in 4: put_battlefield(0, "Forest")
	give_hand(0, "Giant Spider")
	give_hand(0, "Grizzly Bears")
	give_hand(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	assert_string_contains(pilot.act(g), "Grizzly Bears")
	resolve_stack()
	assert_false(pilot._action_line.is_empty())
	g.adjust_life(1, -1)
	assert_string_contains(pilot.act(g), "Grizzly Bears")
	assert_gt(pilot.last_action_nodes, 0, "changed public state must be searched again")


func test_hidden_substitution_preserves_a_saved_action_line() -> void:
	var profile := AiProfile.wizard()
	profile.action_search_nodes = 96
	var pilot := AiPlayer.new(0, profile)
	g.set_agent(0, pilot)
	for _i in 4: put_battlefield(0, "Forest")
	give_hand(0, "Giant Spider")
	give_hand(0, "Grizzly Bears")
	give_hand(0, "Grizzly Bears")
	var hidden := give_hand(1, "Giant Growth")
	advance_to_step(Mtg.Step.MAIN1)
	assert_string_contains(pilot.act(g), "Grizzly Bears")
	resolve_stack()
	hidden.data = CardRegistry.get_card("Wrath of God")
	g.players[1].deck_names.assign(["Wrath of God"])
	g.players[0].library.reverse()
	assert_string_contains(pilot.act(g), "Grizzly Bears")
	assert_eq(pilot.last_action_nodes, 0, "secret changes cannot invalidate a public cache key")


func test_lethal_has_priority_and_zero_budget_keeps_a_legal_fallback() -> void:
	var planner := AiActionPlanner.new()
	var options := [{"id": 1, "value": 900.0, "independent": false},
		{"id": 2, "value": 800.0, "independent": true},
		{"id": 3, "value": 800.0, "independent": true}]
	var payable := func(_line: Array) -> bool: return true
	assert_eq(planner.choose(options, payable)[0]["id"], 1)
	assert_eq(planner.nodes, 0)
	planner.budget = 0
	options.remove_at(0)
	assert_eq(planner.choose(options, payable)[0]["id"], 2)
	assert_eq(planner.nodes, 0)
