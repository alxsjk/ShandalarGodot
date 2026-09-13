extends GameTest


func test_unfair_is_a_separate_wizard_not_a_profile_override() -> void:
	var unfair := UnfairPlayer.new(0)
	assert_true(unfair is AiPlayer)
	var wizard := AiProfile.wizard()
	for property in wizard.get_property_list():
		if int(property.usage) & PROPERTY_USAGE_SCRIPT_VARIABLE:
			assert_eq(unfair.profile.get(property.name), wizard.get(property.name), str(property.name))
	assert_ne(wizard.apply_overrides("sees_hidden_hand=on"), "")
	var config := DuelConfig.vs_ai_default(AiProfile.apprentice())
	assert_false(config.create_ai(1) is UnfairPlayer)
	config.unfair[1] = true
	assert_true(config.create_ai(1) is UnfairPlayer)
	assert_eq(config.create_ai(1).profile.profile_name, "Wizard")
	assert_string_contains(config.challenge_label(), "Hand visible to opponent")
	assert_eq(config.hidden_seats(), [1], "the challenge never exposes its hand to the human")


func test_known_counter_changes_real_cast_order_but_unaffordable_counter_does_not() -> void:
	for _i in 6: put_battlefield(0, "Forest")
	var island := put_battlefield(1, "Island")
	put_battlefield(1, "Island")
	give_hand(1, "Counterspell")
	give_hand(0, "Giant Spider")
	give_hand(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN2)
	var unfair := UnfairPlayer.new(0)
	g.set_agent(0, unfair)
	var mark := g.make_mark()
	assert_string_contains(unfair._try_cast_best(g), "Grizzly Bears", "bait before the larger threat")
	g.unmake_to(mark)
	g.end_search()
	island.tapped = true
	unfair = UnfairPlayer.new(0)
	g.set_agent(0, unfair)
	assert_string_contains(unfair._try_cast_best(g), "Giant Spider", "one Island cannot pay for Counterspell")


func test_only_unfair_key_changes_with_a_secret_current_hand() -> void:
	var hidden := give_hand(1, "Giant Growth")
	var unfair := UnfairPlayer.new(0)
	var key := unfair._planning_key(g)
	for profile in [AiProfile.apprentice(), AiProfile.magician(), AiProfile.sorcerer(), AiProfile.wizard()]:
		var fair := AiPlayer.new(0, profile)
		hidden.data = CardRegistry.get_card("Giant Growth")
		var before := fair._planning_key(g)
		hidden.data = CardRegistry.get_card("Counterspell")
		assert_eq(fair._planning_key(g), before, profile.profile_name)
	assert_ne(unfair._planning_key(g), key)
	assert_false(hidden.revealed_in_hand)


func test_unfair_key_excludes_libraries_rng_decklist_and_face_down_identity() -> void:
	give_hand(1, "Giant Growth")
	var hidden := put_battlefield(1, "Grizzly Bears")
	hidden.face_down = true
	var unfair := UnfairPlayer.new(0)
	var before := unfair._planning_key(g)
	hidden.data = CardRegistry.get_card("Shivan Dragon")
	g.players[1].deck_names.assign(["Black Lotus"])
	g.players[1].library[0].data = CardRegistry.get_card("Black Lotus")
	g.players[0].library.reverse()
	g.rng.randf()
	assert_eq(unfair._planning_key(g), before)
	g.players[1].hand.clear()
	assert_false(unfair._planning_key(g).contains("Giant Growth"), "no retained departed-hand identity")


func test_known_growth_changes_combat_without_spending_real_resources() -> void:
	var attacker := put_battlefield(0, "Hill Giant")
	put_battlefield(1, "Grizzly Bears")
	put_battlefield(1, "Forest")
	give_hand(1, "Giant Growth")
	var candidates: Array[CardInstance] = [attacker]
	var fair := AiPlayer.new(0, AiProfile.wizard())
	var unfair := UnfairPlayer.new(0)
	var before := unfair._planning_key(g)
	var rng_before := g.rng.state
	assert_has(fair._attack_choice(g, candidates, 1), attacker.id)
	assert_does_not_have(unfair._attack_choice(g, candidates, 1), attacker.id)
	assert_eq(unfair._planning_key(g), before)
	assert_eq(g.rng.state, rng_before)
	assert_null(g.undo_log)


func test_known_sweeper_holds_extra_creatures_only_in_unfair() -> void:
	for _i in 4: put_battlefield(1, "Plains")
	give_hand(1, "Wrath of God")
	put_battlefield(0, "Hill Giant")
	put_battlefield(0, "Hill Giant")
	for _i in 2: put_battlefield(0, "Forest")
	var bear := give_hand(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN2)
	var unfair := UnfairPlayer.new(0)
	var fair := AiPlayer.new(0, AiProfile.wizard())
	assert_true(unfair._plan_spell_choice(g, bear, 0).is_empty())
	assert_false(fair._plan_spell_choice(g, bear, 0).is_empty())


func test_growth_does_not_make_a_mana_creature_tap_and_block() -> void:
	var attacker := put_battlefield(0, "Hill Giant")
	put_battlefield(1, "Llanowar Elves")
	give_hand(1, "Giant Growth")
	var unfair := UnfairPlayer.new(0)
	var candidates: Array[CardInstance] = [attacker]
	assert_has(unfair._attack_choice(g, candidates, 1), attacker.id)


func test_restricted_known_response_does_not_change_the_plan() -> void:
	var attacker := put_battlefield(0, "Hill Giant")
	put_battlefield(1, "Grizzly Bears")
	put_battlefield(1, "Forest")
	var pump := give_hand(1, "Giant Growth")
	pump.data = CardData.new("Test restricted pump", "{G}", Mtg.CardType.INSTANT) \
		.spell(PumpEffect.new(3, 3)).castable_only_when(
			func(_game: MtgGame, _seat: int) -> String: return "not now")
	var unfair := UnfairPlayer.new(0)
	var candidates: Array[CardInstance] = [attacker]
	assert_has(unfair._attack_choice(g, candidates, 1), attacker.id)
