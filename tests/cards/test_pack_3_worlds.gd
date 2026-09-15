extends GameTest

func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()
	advance_to_step(Mtg.Step.MAIN1)

func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)

func aura(name: String, host: CardInstance) -> CardInstance:
	var a := give_hand(0, name)
	g.attach_aura_from_anywhere(a, host, 0)
	return a

func test_infernal_darkness_recolors_lands_not_elves_or_land_types() -> void:
	put_battlefield(0, "Infernal Darkness")
	var forest := put_battlefield(0, "Forest")
	var elf := put_battlefield(0, "Llanowar Elves")
	assert_ok(g.tap_for_mana(0, forest))
	assert_ok(g.tap_for_mana(0, elf))
	assert_true(forest.has_subtype("forest"))
	assert_true(g.players[0].mana_pool.can_pay(ManaCost.parse("{B}{G}")))

func test_replacements_preserve_mana_amount_and_restricted_outputs() -> void:
	put_battlefield(0, "Ritual of Subdual")
	var workshop := put_battlefield(0, "Mishra's Workshop")
	assert_ok(g.tap_for_mana(0, workshop))
	assert_false(g.players[0].mana_pool.can_pay(ManaCost.parse("{3}")))
	assert_true(g.players[0].mana_pool.can_pay(ManaCost.parse("{3}"), 0, ["artifact"]))

func test_two_mana_replacements_offer_both_legal_final_colors() -> void:
	put_battlefield(0, "Infernal Darkness")
	put_battlefield(0, "Ritual of Subdual")
	var forest := put_battlefield(0, "Forest")
	var outputs: Array[int] = []
	for ability in forest.cur_mana_abilities: outputs.append(ability.produces[0][0])
	assert_has(outputs, Mtg.ManaColor.B)
	assert_has(outputs, Mtg.ManaColor.C)
	assert_eq(outputs.size(), 2)
	assert_true(g.try_pay(0, ManaCost.parse("{B}")))

func test_naked_singularity_dual_land_has_two_replacement_choices() -> void:
	put_battlefield(0, "Naked Singularity")
	var dual := put_battlefield(0, "Tundra")
	var outputs: Array[int] = []
	for ability in dual.cur_mana_abilities: outputs.append(ability.produces[0][0])
	assert_has(outputs, Mtg.ManaColor.R)
	assert_has(outputs, Mtg.ManaColor.G)
	assert_false(outputs.has(Mtg.ManaColor.W))
	assert_false(outputs.has(Mtg.ManaColor.U))

func test_deep_water_is_visible_to_the_mana_planner() -> void:
	var deep := put_battlefield(0, "Deep Water")
	var mountain := put_battlefield(0, "Mountain")
	add_mana(0, Mtg.ManaColor.U)
	assert_ok(g.activate_ability(0, deep, 0))
	resolve_stack()
	assert_eq(mountain.cur_mana_abilities[0].produces[0][0], Mtg.ManaColor.U)
	assert_true(g.try_pay(0, ManaCost.parse("{U}")))

func test_glaciers_changes_mountain_types_and_mana() -> void:
	put_battlefield(0, "Glaciers")
	var mountain := put_battlefield(1, "Mountain")
	assert_true(mountain.has_subtype("plains"))
	assert_false(mountain.has_subtype("mountain"))
	assert_eq(mountain.cur_mana_abilities[0].produces[0][0], Mtg.ManaColor.W)

func test_illusionary_terrain_changes_basic_but_not_nonbasic_mountains() -> void:
	put_battlefield(0, "Illusionary Terrain")
	var mountain := put_battlefield(1, "Snow-Covered Mountain")
	var dual := put_battlefield(1, "Taiga")
	assert_true(mountain.has_subtype("island"))
	assert_true(dual.has_subtype("mountain"))
	assert_true((mountain.cur_supertypes & Mtg.Supertype.SNOW) != 0)

func test_wind_counters_replace_untap_but_not_an_untap_spell() -> void:
	put_battlefield(0, "Freyalise's Winds")
	var land := put_battlefield(1, "Island")
	g.tap_permanent(land)
	resolve_stack()
	assert_eq(int(land.counters.get("wind", 0)), 1)
	g.active_player = 1
	assert_true(g._untap_step())
	assert_true(land.tapped)
	assert_eq(int(land.counters.get("wind", 0)), 0)
	g.add_counters(land, "wind", 2)
	g.untap_permanent(land)
	assert_false(land.tapped)
	assert_eq(int(land.counters.get("wind", 0)), 2)

func test_wind_trigger_does_not_put_a_counter_on_a_returned_card() -> void:
	put_battlefield(0, "Freyalise's Winds")
	var bear := put_battlefield(1, "Grizzly Bears")
	g.tap_permanent(bear)
	g.return_to_hand(bear)
	g._put_on_battlefield(bear, 1)
	resolve_stack()
	assert_eq(int(bear.counters.get("wind", 0)), 0)

func test_halls_reads_the_controllers_actual_last_turn_not_previous_global_turn() -> void:
	put_battlefield(0, "Halls of Mist")
	var bear := put_battlefield(0, "Grizzly Bears")
	run_combat([bear.id])
	advance_to_next_turn()
	assert_true(bear.cur_cant_attack)
	g.change_control(bear, 1)
	assert_false(bear.cur_cant_attack)

func test_brand_ban_follows_host_controller() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	aura("Brand of Ill Omen", bear)
	assert_ne(g.play_banned(1, CardRegistry.get_card("Grizzly Bears")), "")
	assert_eq(g.play_banned(0, CardRegistry.get_card("Grizzly Bears")), "")
	g.change_control(bear, 0)
	assert_ne(g.play_banned(0, CardRegistry.get_card("Grizzly Bears")), "")
	assert_eq(g.play_banned(1, CardRegistry.get_card("Grizzly Bears")), "")

func test_aggression_destroys_nonattacker_even_after_aura_leaves() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	var a := aura("Aggression", bear)
	g.dispatch_event(Mtg.EventType.END_STEP_START, {"player": 1})
	g.return_to_hand(a)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)

func test_prismatic_ward_prevents_red_but_not_blue_damage() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	aura("Prismatic Ward", bear)
	var red := put_battlefield(1, "Prodigal Pyromancer") if CardRegistry.has_card("Prodigal Pyromancer") else put_battlefield(1, "Orcish Artillery")
	var blue := put_battlefield(1, "Prodigal Sorcerer")
	g.deal_damage(red, TargetRef.card(bear), 3)
	assert_eq(bear.damage, 0)
	g.deal_damage(blue, TargetRef.card(bear), 1)
	assert_eq(bear.damage, 1)

func test_chromatic_armor_enforces_current_counter_count_as_x() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	var a := aura("Chromatic Armor", bear)
	add_mana(0, Mtg.ManaColor.C, 5)
	assert_refused(g.activate_ability(0, a, 0, [], 0), "sleight")
	assert_ok(g.activate_ability(0, a, 0, [], 1))
	resolve_stack()
	assert_eq(int(a.counters.get("sleight", 0)), 2)
	assert_refused(g.activate_ability(0, a, 0, [], 1), "sleight")

func test_snowblind_reduces_to_one_toughness_not_zero() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	for _i in 4: put_battlefield(1, "Snow-Covered Forest")
	aura("Snowblind", bear)
	assert_eq(bear.cur_power, -2)
	assert_eq(bear.cur_toughness, 1)
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
