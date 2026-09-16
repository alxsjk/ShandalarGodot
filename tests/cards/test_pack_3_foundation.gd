extends GameTest

func test_snowfall_planner_keeps_restricted_bonus_distinct_from_island_mana() -> void:
	put_battlefield(0, "Snowfall")
	put_battlefield(0, "Snow-Covered Island")
	advance_to_step(Mtg.Step.UPKEEP)
	# Test the planner at upkeep, independently of paying Snowfall itself.
	g.stack.clear()
	assert_false(g.can_afford_cost(0, ManaCost.parse("{U}{U}{U}")))
	assert_true(g.can_afford_cost(0, ManaCost.parse("{U}{U}{U}"), ["cumulative_upkeep"]))
	assert_true(g.try_pay(0, ManaCost.parse("{U}{U}{U}"), ["cumulative_upkeep"]))
## Ice Age catalogue and shared mechanisms; individual card audits have
## separate behavioral tests. Presence in this catalogue is not rules QA.

func before_each() -> void:
	CardPacks.set_enabled(CardPacks.ID, false)
	CardPacks.set_enabled(FallenEmpiresPack.ID, false)
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()

func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)
	CardPacks.set_enabled(FallenEmpiresPack.ID, false)
	CardPacks.set_enabled(CardPacks.ID, false)

func test_catalogue_reuses_original_identities() -> void:
	assert_eq(IceAgePack.records().size(), 373)
	assert_eq(IceAgePack.new_names().size(), 346)
	assert_eq(CardRegistry.size(), 1243)
	assert_eq(CardRegistry.names_in_set("ice").size(), 373)
	assert_eq(CardRegistry.named_set_entry_count(), 1270)
	for name in IceAgePack.names():
		assert_true(CardRegistry.has_card(name), name)
		var data := CardRegistry.get_card(name)
		assert_false(data.cast_condition.is_valid() and data.cast_condition.get_method() == "_pending", name + " has reviewed executable rules")
	assert_eq(CardRegistry.get_card("Counterspell").set_code, "2ed")
	assert_eq(CardPacks.packs_required_by(["Counterspell", "Forest"]), [])
	assert_eq(CardPacks.packs_required_by(["Snow-Covered Forest", "Necropotence"]), ["pack-3"])
	CardPacks.set_enabled(CardPacks.ID, true)
	CardPacks.set_enabled(FallenEmpiresPack.ID, true)
	assert_eq(CardRegistry.size(), 1349)
	assert_eq(CardRegistry.named_set_entry_count(), 1745)

func test_ice_age_only_filter_includes_reprints() -> void:
	var filter := DeckFilter.new()
	filter.original_cards_on = false
	filter.completion_pack_on = false
	var pool: Array[CardData] = []
	for name in CardRegistry.all_names(): pool.append(CardRegistry.get_card(name))
	var found := filter.apply(pool)
	assert_eq(found.size(), 373)
	for data in found: assert_eq(filter.preferred_printing(data), "ice", data.card_name)
	filter.toggle_set("ice")
	assert_eq(filter.apply(pool).size(), 0)

func test_snow_basics_have_their_real_mana_and_basic_status() -> void:
	for type in Mtg.BASIC_LAND_COLORS:
		var land := put_battlefield(0, "Snow-Covered " + String(type).capitalize())
		assert_true((land.cur_supertypes & Mtg.Supertype.SNOW) != 0)
		assert_true((land.cur_supertypes & Mtg.Supertype.BASIC) != 0)
		assert_ok(g.tap_for_mana(0, land, 0))
		assert_eq(g.players[0].mana_pool.amount_of(Mtg.BASIC_LAND_COLORS[type]), 1)

func test_snow_walk_requires_both_snow_and_the_named_type() -> void:
	put_battlefield(1, "Forest")
	assert_false(CombatState._controls_land_of_type(g, 1, "snow forest"))
	put_battlefield(1, "Snow-Covered Island")
	assert_false(CombatState._controls_land_of_type(g, 1, "snow forest"))
	put_battlefield(1, "Snow-Covered Forest")
	assert_true(CombatState._controls_land_of_type(g, 1, "snow forest"))

func test_cumulative_upkeep_scales_and_sacrifices_when_unaffordable() -> void:
	var wall := put_battlefield(0, "Illusionary Wall")
	add_mana(0, Mtg.ManaColor.U, 3)
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 0})
	resolve_stack()
	assert_eq(int(wall.counters.get("age", 0)), 1)
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.U), 2)
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 0})
	resolve_stack()
	assert_eq(int(wall.counters.get("age", 0)), 2)
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.U), 0)
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 0})
	resolve_stack()
	assert_eq(wall.zone, Mtg.Zone.GRAVEYARD)

func test_cumulative_trigger_does_not_charge_a_new_incarnation() -> void:
	var wall := put_battlefield(0, "Illusionary Wall")
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 0})
	g.return_to_hand(wall)
	g._put_on_battlefield(wall, 0)
	resolve_stack()
	assert_eq(wall.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(int(wall.counters.get("age", 0)), 0)

func test_upkeep_restricted_mana_is_planned_and_paid_only_for_upkeep() -> void:
	var unicorn := put_battlefield(0, "Adarkar Unicorn")
	assert_false(g.can_afford_cost(0, ManaCost.parse("{U}")))
	assert_true(g.can_afford_cost(0, ManaCost.parse("{U}"), CumulativeUpkeep.USAGE))
	assert_true(g.can_afford_cost(0, ManaCost.parse("{1}{U}"), CumulativeUpkeep.USAGE))
	assert_true(g.try_pay(0, ManaCost.parse("{U}"), CumulativeUpkeep.USAGE))
	assert_true(unicorn.tapped)
	g.players[0].mana_pool.add_restricted(Mtg.ManaColor.U, 2, "cumulative_upkeep")
	assert_false(g.can_afford_cost(0, ManaCost.parse("{U}")))
	assert_true(g.can_afford_cost(0, ManaCost.parse("{U}{U}"), CumulativeUpkeep.USAGE))
	assert_true(g.try_pay(0, ManaCost.parse("{U}{U}"), CumulativeUpkeep.USAGE))

func test_cantrip_waits_for_next_turn_and_retains_original_recipient() -> void:
	var pyknite := put_battlefield(0, "Pyknite")
	resolve_stack()
	var before := g.players[0].hand.size()
	g.change_control(pyknite, 1)
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 1})
	resolve_stack()
	assert_eq(g.players[0].hand.size(), before)
	g.turn_number += 1
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 1})
	resolve_stack()
	assert_eq(g.players[0].hand.size(), before + 1)
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 0})
	resolve_stack()
	assert_eq(g.players[0].hand.size(), before + 1)

func test_painland_only_hurts_for_colored_mana() -> void:
	var land := put_battlefield(0, "Adarkar Wastes")
	assert_ok(g.tap_for_mana(0, land, 0))
	assert_eq(g.players[0].life, 20)
	g.untap_permanent(land)
	assert_ok(g.tap_for_mana(0, land, 1))
	assert_eq(g.players[0].life, 19)

func test_depletion_counter_locks_and_upkeep_removes_it() -> void:
	var land := put_battlefield(0, "Land Cap")
	assert_ok(g.tap_for_mana(0, land, 0))
	assert_true(land.cur_skips_untap)
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 0})
	resolve_stack()
	assert_eq(int(land.counters.get("depletion", 0)), 0)
	assert_false(land.cur_skips_untap)
