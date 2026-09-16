extends GameTest

func before_each() -> void:
	CardPacks.set_enabled("pack-5", true)
	super()
	advance_to_step(Mtg.Step.MAIN1)

func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-5", false)

func test_adnate_can_sacrifice_itself_for_its_mana_value() -> void:
	var a := put_battlefield(0, "Soldevi Adnate")
	assert_ok(g.tap_for_mana(0, a))
	assert_eq(a.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.B), 2)

func test_library_exile_cost_is_face_up_and_no_partial_payment() -> void:
	var c := put_battlefield(0, "Whirling Catapult")
	add_mana(0, Mtg.ManaColor.C, 2)
	assert_ok(g.activate_ability(0, c, 0))
	assert_eq(g.players[0].exile.size(), 2)
	for i in g.players[0].exile: assert_false(i.face_down)
	resolve_stack()

func test_regenerating_a_tapped_steam_beast_does_not_trigger_another_life_gain() -> void:
	var c := put_battlefield(0, "Soldevi Steam Beast")
	add_mana(0, Mtg.ManaColor.C, 4)
	assert_ok(g.activate_ability(0, c, 0))
	resolve_stack()
	g.destroy(c)
	resolve_stack()
	assert_eq(g.players[1].life, 22)
	assert_ok(g.activate_ability(0, c, 0))
	resolve_stack()
	g.destroy(c)
	resolve_stack()
	assert_eq(g.players[1].life, 22)
	assert_eq(c.regenerations_this_turn, 2)

func test_storm_cauldron_adds_one_land_drop_and_bounces_mana_land_on_stack() -> void:
	put_battlefield(0, "Storm Cauldron")
	var first := give_hand(0, "Forest")
	var second := give_hand(0, "Forest")
	var third := give_hand(0, "Forest")
	assert_ok(g.play_land(0, first))
	assert_ok(g.play_land(0, second))
	assert_refused(g.play_land(0, third))
	assert_ok(g.tap_for_mana(0, first))
	assert_eq(first.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.G), 1)
	resolve_stack()
	assert_eq(first.zone, Mtg.Zone.HAND)

func test_sustaining_spirit_protects_only_damage_not_life_payments() -> void:
	put_battlefield(0, "Sustaining Spirit")
	var bolt := give_hand(1, "Lightning Bolt")
	g.deal_damage(bolt, TargetRef.player(0), 30)
	assert_eq(g.players[0].life, 1)
	g.adjust_life(0, -1)
	assert_eq(g.players[0].life, 0)

func test_viscerid_drone_sacrifices_two_distinct_permanents_before_resolution() -> void:
	var drone := put_battlefield(0, "Viscerid Drone")
	var food := put_battlefield(0, "Grizzly Bears")
	var swamp := put_battlefield(0, "Swamp")
	var enemy := put_battlefield(1, "Serra Angel")
	# Keep the Drone by preferring the other eligible creature.
	g.players[0].battlefield.erase(food)
	g.players[0].battlefield.push_front(food)
	assert_ok(g.activate_ability(0, drone, 0, [TargetRef.card(enemy)]))
	assert_eq(food.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(swamp.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(enemy.zone, Mtg.Zone.BATTLEFIELD)
	resolve_stack()
	assert_eq(enemy.zone, Mtg.Zone.GRAVEYARD)

func test_benthic_explorers_untaps_opponents_land_as_a_cost() -> void:
	var c := put_battlefield(0, "Benthic Explorers")
	var land := put_battlefield(1, "Island")
	assert_refused(g.tap_for_mana(0, c))
	g.tap_permanent(land)
	assert_ok(g.tap_for_mana(0, c))
	assert_false(land.tapped)
	assert_true(c.tapped)
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.U), 1)

func test_natures_chosen_host_tap_cost_works_on_summoning_sick_creature() -> void:
	var host := put_battlefield(0, "Savannah Lions")
	host.summoning_sick = true
	var land := put_battlefield(0, "Forest")
	g.tap_permanent(land)
	var aura := give_hand(0, "Nature's Chosen")
	add_mana(0, Mtg.ManaColor.G)
	assert_ok(g.cast_spell(0, aura, [TargetRef.card(host)]))
	resolve_stack()
	assert_ok(g.activate_ability(0, aura, 1, [TargetRef.card(land)]))
	assert_true(host.tapped)
	resolve_stack()
	assert_false(land.tapped)
