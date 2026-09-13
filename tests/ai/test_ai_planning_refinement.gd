extends GameTest


func test_modal_creature_with_draw_effect_cannot_leave_a_cached_development_line() -> void:
	var pilot := AiPlayer.new(0, AiProfile.wizard())
	g.set_agent(0, pilot)
	for _i in 4: put_battlefield(0, "Forest")
	var modal := give_hand(0, "Grizzly Bears")
	modal.data = CardData.new("Test modal creature", "{1}{G}", Mtg.CardType.CREATURE) \
		.pt(20, 20).mode("Draw", [DrawEffect.new(1)])
	give_hand(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN2)
	assert_ne(pilot._try_cast_best(g), "")
	assert_true(pilot._action_line.is_empty(), "a modal draw is an uncertainty boundary")


func test_context_value_respects_null_hidden_substitution_and_nested_search() -> void:
	var lord := put_battlefield(1, "Lord of Atlantis")
	put_battlefield(1, "Merfolk of the Pearl Trident")
	var secret := give_hand(1, "Giant Growth")
	var profile := AiProfile.wizard()
	var pilot := AiPlayer.new(0, profile)
	var mark := g.make_mark()
	g.adjust_life(0, 2)
	var value := pilot._victim_value(g, lord)
	secret.data = CardRegistry.get_card("Counterspell")
	g.players[1].library.reverse()
	assert_eq(pilot._victim_value(g, lord), value)
	assert_not_null(g.undo_log)
	assert_eq(g.players[0].life, 22)
	profile.values_context = false
	assert_eq(pilot._victim_value(g, lord), Evaluator.permanent_value(lord, profile))
	g.unmake_to(mark)
	g.end_search()
	assert_eq(g.players[0].life, 20)


func test_mode_study_does_not_buy_a_prevention_shield_for_no_incoming_damage() -> void:
	var pilot := AiPlayer.new(0, AiProfile.wizard())
	put_battlefield(0, "Plains")
	put_battlefield(1, "Shivan Dragon")
	var salve := give_hand(0, "Healing Salve")
	advance_to_step(Mtg.Step.MAIN2)
	var choice := pilot._plan_spell_choice(g, salve, 0)
	assert_false(choice.is_empty())
	if not choice.is_empty(): assert_eq(choice.mode, 0)


func test_support_creature_value_includes_its_public_board_contribution() -> void:
	var pilot := AiPlayer.new(0, AiProfile.wizard())
	var lord := put_battlefield(1, "Lord of Atlantis")
	var alone := pilot._victim_value(g, lord)
	put_battlefield(1, "Merfolk of the Pearl Trident")
	var before := AiObservation.key(g, 0)
	var rng_before := g.rng.state
	assert_gt(pilot._victim_value(g, lord), alone)
	assert_eq(AiObservation.key(g, 0), before, "a valuation must not alter the duel")
	assert_eq(g.rng.state, rng_before)
	assert_null(g.undo_log)


func test_modal_planner_can_leave_an_unusable_first_mode() -> void:
	var pilot := AiPlayer.new(0, AiProfile.wizard())
	g.set_agent(0, pilot)
	put_battlefield(0, "Swamp")
	var victim := put_battlefield(1, "Grizzly Bears")
	var spell := give_hand(0, "Terror")
	spell.data = CardData.new("Test modal removal", "{B}", Mtg.CardType.SORCERY) \
		.mode("Destroy artifact", CardRegistry.get_card("Shatter").spell_effects) \
		.mode("Destroy creature", [DestroyEffect.new(TargetSpec.creature())])
	advance_to_step(Mtg.Step.MAIN1)
	assert_string_contains(pilot.act(g), "Test modal removal")
	assert_eq(g.stack.size(), 1)
	if not g.stack.is_empty():
		assert_eq(g.stack.back().mode, 1)
		assert_eq(g.stack.back().targets[0].instance_id, victim.id)
	resolve_stack()
	assert_eq(victim.zone, Mtg.Zone.GRAVEYARD)


func test_modal_planner_prices_modes_not_just_the_first_legal_target() -> void:
	var pilot := AiPlayer.new(0, AiProfile.wizard())
	g.set_agent(0, pilot)
	put_battlefield(0, "Swamp")
	put_battlefield(1, "Grizzly Bears")
	var victim := put_battlefield(1, "Sol Ring")
	var spell := give_hand(0, "Terror")
	spell.data = CardData.new("Test modal removal", "{B}", Mtg.CardType.SORCERY) \
		.mode("Gain life", [GainLifeEffect.new(1)]) \
		.mode("Destroy artifact", CardRegistry.get_card("Shatter").spell_effects)
	advance_to_step(Mtg.Step.MAIN1)
	assert_string_contains(pilot.act(g), "Test modal removal")
	if not g.stack.is_empty():
		assert_eq(g.stack.back().mode, 1)
	resolve_stack()
	assert_eq(victim.zone, Mtg.Zone.GRAVEYARD)
