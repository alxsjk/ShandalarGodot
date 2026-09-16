extends GameTest

func before_each() -> void:
	CardPacks.set_enabled("pack-4", true)
	super()
	advance_to_step(Mtg.Step.MAIN1)

func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-4", false)

func test_sengir_autocrat_creates_three_and_exiles_all_serf_tokens_when_leaving() -> void:
	var autocrat := put_battlefield(0, "Sengir Autocrat")
	resolve_stack()
	assert_eq(g.players[0].battlefield.size(), 4)
	var serf := g.players[0].battlefield[1]
	assert_eq(serf.cur_toughness, 1)
	assert_true(serf.is_token)
	g.create_token(1, serf.data)
	g.return_to_hand(autocrat)
	resolve_stack()
	assert_eq(g.players[0].battlefield.size(), 0)
	assert_eq(g.players[1].battlefield.size(), 0)

func test_drudge_spell_exiles_two_corpses_as_cost_and_tokens_really_regenerate() -> void:
	var drudge := put_battlefield(0, "Drudge Spell")
	var a := put_battlefield(0, "Grizzly Bears")
	var b := put_battlefield(0, "Mesa Falcon")
	g.destroy(a)
	add_mana(0, Mtg.ManaColor.B, 3)
	assert_refused(g.activate_ability(0, drudge, 0))
	assert_eq(a.zone, Mtg.Zone.GRAVEYARD)
	g.destroy(b)
	assert_ok(g.activate_ability(0, drudge, 0))
	assert_eq(a.zone, Mtg.Zone.EXILE)
	assert_eq(b.zone, Mtg.Zone.EXILE)
	resolve_stack()
	assert_eq(g.players[0].battlefield.size(), 2)
	if g.players[0].battlefield.size() != 2: return
	var skeleton := g.players[0].battlefield[1]
	assert_ok(g.activate_ability(0, skeleton, 0))
	resolve_stack()
	g.destroy(skeleton)
	assert_eq(skeleton.zone, Mtg.Zone.BATTLEFIELD)
	g.return_to_hand(drudge)
	resolve_stack()
	assert_ne(skeleton.zone, Mtg.Zone.BATTLEFIELD)

func test_coral_reef_cost_taps_sick_blue_creature_but_not_target_unnecessarily() -> void:
	var reef := put_battlefield(0, "Coral Reef")
	var sprite := put_battlefield(0, "Sea Sprite", true)
	var bear := put_battlefield(0, "Grizzly Bears")
	assert_eq(int(reef.counters.get("polyp", 0)), 4)
	add_mana(0, Mtg.ManaColor.U)
	assert_ok(g.activate_ability(0, reef, 1, [TargetRef.card(bear)]))
	assert_true(sprite.tapped)
	assert_false(bear.tapped)
	assert_eq(int(reef.counters.get("polyp", 0)), 3)
	resolve_stack()
	assert_eq(bear.cur_toughness, 3)
	var island := put_battlefield(0, "Island")
	assert_ok(g.activate_ability(0, reef, 0))
	assert_eq(island.zone, Mtg.Zone.GRAVEYARD)
	resolve_stack()
	assert_eq(int(reef.counters.get("polyp", 0)), 5)

func test_didgeridoo_puts_a_minotaur_from_hand_without_casting_through_storm() -> void:
	put_battlefield(0, "Aether Storm")
	var didgeridoo := put_battlefield(0, "Didgeridoo")
	var minotaur := give_hand(0, "Anaba Bodyguard")
	var bear := give_hand(0, "Grizzly Bears")
	add_mana(0, Mtg.ManaColor.C, 3)
	assert_ok(g.activate_ability(0, didgeridoo, 0))
	resolve_stack()
	assert_eq(minotaur.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(bear.zone, Mtg.Zone.HAND)
	assert_true(minotaur.summoning_sick)

func test_willow_priestess_puts_faeries_and_grants_protection_to_green_only() -> void:
	var priestess := put_battlefield(0, "Willow Priestess")
	var faerie := give_hand(0, "Willow Faerie")
	assert_ok(g.activate_ability(0, priestess, 0))
	resolve_stack()
	assert_eq(faerie.zone, Mtg.Zone.BATTLEFIELD)
	add_mana(0, Mtg.ManaColor.G, 3)
	assert_ok(g.activate_ability(0, priestess, 1, [TargetRef.card(faerie)]))
	resolve_stack()
	assert_ne(faerie.cur_protection & Mtg.ManaColor.B, 0)
	advance_to_next_turn()
	assert_eq(faerie.cur_protection & Mtg.ManaColor.B, 0)

func test_wall_of_kelp_makes_a_plant_wall_with_defender() -> void:
	var wall := put_battlefield(0, "Wall of Kelp")
	add_mana(0, Mtg.ManaColor.U, 2)
	assert_ok(g.activate_ability(0, wall, 0))
	resolve_stack()
	assert_eq(g.players[0].battlefield.size(), 2)
	if g.players[0].battlefield.size() != 2: return
	var token := g.players[0].battlefield[1]
	assert_true(token.has_subtype("plant"))
	assert_true(token.has_subtype("wall"))
	assert_true(token.has_keyword(Mtg.Keyword.DEFENDER))
	assert_eq(token.cur_toughness, 1)

func test_serrated_arrows_spends_arrowheads_before_counter_resolution() -> void:
	var arrows := put_battlefield(0, "Serrated Arrows")
	var bear := put_battlefield(1, "Grizzly Bears")
	assert_eq(int(arrows.counters.get("arrowhead", 0)), 3)
	assert_ok(g.activate_ability(0, arrows, 0, [TargetRef.card(bear)]))
	assert_eq(int(arrows.counters.get("arrowhead", 0)), 2)
	resolve_stack()
	assert_eq(bear.cur_toughness, 1)
	g.remove_counters(arrows, "arrowhead", 2)
	assert_eq(arrows.zone, Mtg.Zone.BATTLEFIELD)
	advance_to_next_turn()
	advance_to_step(Mtg.Step.UPKEEP)
	resolve_stack()
	assert_eq(arrows.zone, Mtg.Zone.GRAVEYARD)

func test_reveka_and_alchemist_use_real_damage_prevention_and_next_untap_lock() -> void:
	var reveka := put_battlefield(0, "Reveka, Wizard Savant")
	var alchemist := put_battlefield(0, "Samite Alchemist")
	var bear := put_battlefield(0, "Grizzly Bears")
	add_mana(0, Mtg.ManaColor.W, 2)
	assert_ok(g.activate_ability(0, alchemist, 0, [TargetRef.card(bear)]))
	resolve_stack()
	assert_true(bear.tapped)
	assert_ok(g.activate_ability(0, reveka, 0, [TargetRef.card(bear)]))
	resolve_stack()
	assert_eq(bear.damage, 0)
	assert_eq(reveka.skip_untap_for, [0])
	advance_to_next_turn()
	advance_to_next_turn()
	assert_true(bear.tapped)
	assert_true(reveka.tapped)
