extends GameTest
## The four new rules identities in Pack 1. Reprints use their existing
## implementations; these are the only new behaviours the pack unlocks.


func before_each() -> void:
	CardPacks.set_enabled(CardPacks.ID, true)
	super()


func after_each() -> void:
	g = null
	CardPacks.set_enabled(CardPacks.ID, false)


func _wizard() -> AiPlayer:
	var ai := AiPlayer.new(0, AiProfile.wizard())
	g.set_agent(0, ai)
	return ai


func _coin_seed(wanted_win: bool) -> int:
	for seed_value in range(1, 100):
		var picker := RandomNumberGenerator.new()
		picker.seed = seed_value
		if ((picker.randi() % 2) == 0) == wanted_win:
			return seed_value
	return -1


func test_every_adaptation_labels_itself() -> void:
	for name in CardPacks.ADDED_NAMES:
		var card := CardRegistry.get_card(name)
		assert_not_null(card, String(name))
		assert_true(card.oracle_text.begins_with("Digital adaptation —"),
			String(name))


func test_every_pack_card_is_visible_in_the_deck_builder() -> void:
	var screen: DeckBuilderScreen = load(
		"res://game/deck_builder/deck_builder_screen.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame
	assert_eq(CardRegistry.size(), 901, "the enabled playable pool")
	assert_eq(screen._inventory.entry_count(), 901,
		"a fresh Deck Builder lists every playable identity")
	var shown := {}
	for entry in screen._inventory._visible_entries():
		shown[entry[0].card_name] = true
	for name in CardRegistry.all_names():
		assert_true(shown.has(name), "%s is in the Deck Builder" % name)
	for name in CardPacks.ADDED_NAMES:
		assert_true(shown.has(name), "%s is not hidden as optional code" % name)

	# Reprints remain one playable rules identity, but selecting any one of
	# their printed sets must reveal them. Together these eight views cover
	# all 1,270 named set entries supplied by Pack 1.
	var named_entries := 0
	var pool: Array[CardData] = []
	for name in CardRegistry.all_names():
		pool.append(CardRegistry.get_card(name))
	for code in CardRegistry.SET_ORDER:
		var one_set := DeckFilter.new()
		for other in CardRegistry.SET_ORDER:
			if other != code:
				one_set.toggle_set(other)
		var expected := CardRegistry.names_in_set(code)
		var filtered := one_set.apply(pool)
		named_entries += filtered.size()
		assert_eq(filtered.size(), expected.size(),
			"every %s checklist entry is reachable through its set filter" % code)
		var filtered_names := {}
		for data in filtered:
			filtered_names[data.card_name] = true
		for name in expected:
			assert_true(filtered_names.has(name), "%s / %s is visible" % [code, name])
	assert_eq(named_entries, 1270, "all Pack 1 named set entries are visible")


func test_pack_mechanics_are_shared_effects_the_ai_can_read() -> void:
	var orb := CardRegistry.get_card("Chaos Orb").activated_abilities[0].effects[0]
	var star := CardRegistry.get_card("Falling Star").spell_effects[0]
	var subgame := CardRegistry.get_card("Shahrazad").spell_effects[0]
	var command := CardRegistry.get_card("Word of Command").spell_effects[0]
	assert_true(orb is RandomDestroyEffect)
	assert_true(star is CoinFlipDamageEffect)
	assert_true(subgame is CoinFlipLifeLossEffect)
	assert_true(command is ChosenDiscardEffect)
	var orb_intent := EffectIntent.read([orb], "Chaos Orb")
	var star_intent := EffectIntent.read([star], "Falling Star")
	var subgame_intent := EffectIntent.read([subgame], "Shahrazad")
	var command_intent := EffectIntent.read([command], "Word of Command")
	assert_not_null(orb_intent.random_destroy)
	assert_not_null(star_intent.coin_damage)
	assert_not_null(subgame_intent.coin_life_loss)
	assert_not_null(command_intent.chosen_discard)
	assert_eq(command_intent.discards, 1)
	for intent in [orb_intent, star_intent, subgame_intent, command_intent]:
		assert_false(intent.unknown, "Pack 1 effects are structural AI vocabulary")


func test_chaos_orb_won_flip_destroys_one_opposing_nontoken_and_itself() -> void:
	var orb := put_battlefield(0, "Chaos Orb")
	var bear := put_battlefield(1, "Grizzly Bears")
	var token := put_battlefield(1, "Savannah Lions")
	token.is_token = true
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.C)
	assert_ok(g.activate_ability(0, orb, 0, [TargetRef.player(1)]))
	g.rng.seed = _coin_seed(true)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(token.zone, Mtg.Zone.BATTLEFIELD, "tokens are outside the lottery")
	assert_eq(orb.zone, Mtg.Zone.GRAVEYARD)


func test_chaos_orb_lost_flip_spares_the_target_but_still_destroys_itself() -> void:
	var orb := put_battlefield(0, "Chaos Orb")
	var bear := put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.C)
	assert_ok(g.activate_ability(0, orb, 0, [TargetRef.player(1)]))
	g.rng.seed = _coin_seed(false)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(orb.zone, Mtg.Zone.GRAVEYARD)


func test_chaos_orb_does_nothing_if_removed_before_resolution() -> void:
	var orb := put_battlefield(0, "Chaos Orb")
	var bear := put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.C)
	assert_ok(g.activate_ability(0, orb, 0, [TargetRef.player(1)]))
	g.destroy(orb)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD,
		"the printed if-this-is-on-the-battlefield condition is preserved")


func test_ai_prices_the_orb_lottery_and_uses_it_on_a_large_threat() -> void:
	var orb := put_battlefield(0, "Chaos Orb")
	var serra := put_battlefield(1, "Serra Angel")
	advance_to_step(Mtg.Step.MAIN1)
	var ai := _wizard()
	add_mana(0, Mtg.ManaColor.C)
	assert_eq(ai.act(g), "activated Chaos Orb")
	assert_eq(g.stack.back().targets[0].player_id, 1)
	g.rng.seed = _coin_seed(true)
	resolve_stack()
	assert_eq(serra.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(orb.zone, Mtg.Zone.GRAVEYARD)


func test_word_of_command_discards_a_chosen_nonland() -> void:
	var word := give_hand(0, "Word of Command")
	var bear := give_hand(1, "Grizzly Bears")
	var forest := give_hand(1, "Forest")
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.B, 2)
	assert_ok(g.cast_spell(0, word, [TargetRef.player(1)]))
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(forest.zone, Mtg.Zone.HAND)


func test_ai_uses_word_of_command_on_the_best_eligible_card() -> void:
	var word := give_hand(0, "Word of Command")
	var bear := give_hand(1, "Grizzly Bears")
	var serra := give_hand(1, "Serra Angel")
	var forest := give_hand(1, "Forest")
	advance_to_step(Mtg.Step.MAIN1)
	var ai := _wizard()
	add_mana(0, Mtg.ManaColor.B, 2)
	assert_eq(ai.act(g), "cast Word of Command")
	resolve_stack()
	assert_eq(serra.zone, Mtg.Zone.GRAVEYARD, "the AI chooses the best nonland")
	assert_eq(bear.zone, Mtg.Zone.HAND)
	assert_eq(forest.zone, Mtg.Zone.HAND)
	assert_eq(word.zone, Mtg.Zone.GRAVEYARD)


func test_ai_does_not_cast_word_of_command_into_an_empty_hand() -> void:
	give_hand(0, "Word of Command")
	advance_to_step(Mtg.Step.MAIN1)
	var ai := _wizard()
	add_mana(0, Mtg.ManaColor.B, 2)
	assert_eq(ai.act(g), "pass")


func test_shahrazad_applies_the_printed_half_life_result_without_a_subgame() -> void:
	var spell := give_hand(0, "Shahrazad")
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.W, 2)
	assert_ok(g.cast_spell(0, spell))
	resolve_stack()
	var lives := [g.players[0].life, g.players[1].life]
	lives.sort()
	assert_eq(lives, [10, 20])


func test_ai_takes_the_shahrazad_wager_only_when_behind() -> void:
	g.players[0].life = 10
	g.players[1].life = 20
	give_hand(0, "Shahrazad")
	advance_to_step(Mtg.Step.MAIN1)
	var ai := _wizard()
	add_mana(0, Mtg.ManaColor.W, 2)
	assert_eq(ai.act(g), "cast Shahrazad")


func test_ai_refuses_a_zero_sum_shahrazad_wager_at_equal_life() -> void:
	give_hand(0, "Shahrazad")
	advance_to_step(Mtg.Step.MAIN1)
	var ai := _wizard()
	add_mana(0, Mtg.ManaColor.W, 2)
	assert_eq(ai.act(g), "pass")


func test_falling_star_flips_separately_for_each_chosen_creature() -> void:
	var spell := give_hand(0, "Falling Star")
	var first := put_battlefield(0, "Craw Wurm")
	var second := put_battlefield(1, "Force of Nature")
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.C, 2)
	add_mana(0, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(0, spell,
		[TargetRef.card(first), TargetRef.card(second)]))
	resolve_stack()
	for creature in [first, second]:
		assert_true(creature.damage == 0 or creature.damage == 3)
		assert_eq(creature.tapped, creature.damage == 3,
			"a won flip both damages and taps its survivor")


func test_falling_star_refuses_more_than_two_targets() -> void:
	var spell := give_hand(0, "Falling Star")
	var first := put_battlefield(1, "Grizzly Bears")
	var second := put_battlefield(1, "Savannah Lions")
	var third := put_battlefield(1, "Scryb Sprites")
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.C, 2)
	add_mana(0, Mtg.ManaColor.R)
	assert_refused(g.cast_spell(0, spell, [TargetRef.card(first),
		TargetRef.card(second), TargetRef.card(third)]), "target")


func test_ai_targets_at_most_two_profitable_enemies_with_falling_star() -> void:
	give_hand(0, "Falling Star")
	var first := put_battlefield(1, "Grizzly Bears")
	var second := put_battlefield(1, "Savannah Lions")
	var third := put_battlefield(1, "Serra Angel")
	var ours := put_battlefield(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	var ai := _wizard()
	add_mana(0, Mtg.ManaColor.C, 2)
	add_mana(0, Mtg.ManaColor.R)
	assert_eq(ai.act(g), "cast Falling Star")
	var ids: Array[int] = []
	for ref in g.stack.back().targets:
		ids.append(ref.instance_id)
	ids.sort()
	assert_eq(ids.size(), 2, "the AI honours the digital footprint cap")
	assert_true(ids.has(third.id), "the AI keeps the highest-value hit")
	assert_true(ids.has(first.id) or ids.has(second.id))
	assert_false(ids.has(ours.id), "the digital adaptation never clips our board")
