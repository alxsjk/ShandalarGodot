extends GameTest


func _list(entries: Dictionary) -> Array:
	var names: Array = []
	for name in entries:
		for _i in int(entries[name]):
			names.append(name)
	return names


func test_studies_low_curve_pressure_without_inspecting_a_game() -> void:
	var study := AiDeckStudy.analyze(_list({"Mountain": 20, "Goblin Rock Sled": 20,
		"Lightning Bolt": 12, "Fireball": 8}))
	assert_eq(study.land_count, 20)
	assert_eq(study.creature_count, 20)
	assert_gt(float(study.plans.get("fast_creatures", 0.0)), 0.0)
	assert_gt(float(study.plans.get("burn", 0.0)), 0.0)
	assert_eq(study.curve[1], 20)


func test_control_ramp_and_land_denial_are_distinct_plans() -> void:
	var control := AiDeckStudy.analyze(_list({"Island": 24, "Counterspell": 12,
		"Ancestral Recall": 12, "Serra Angel": 4, "Swords to Plowshares": 8}))
	var ramp := AiDeckStudy.analyze(_list({"Forest": 24, "Llanowar Elves": 12,
		"Craw Wurm": 12, "Force of Nature": 12}))
	var denial := AiDeckStudy.analyze(_list({"Mountain": 24, "Stone Rain": 12,
		"Ice Storm": 12, "Sol Ring": 4, "Shivan Dragon": 8}))
	assert_eq(control.dominant, "control")
	assert_eq(ramp.dominant, "ramp")
	assert_eq(denial.dominant, "land_control")
	assert_gt(ramp.average_mana, control.average_mana)


func test_combo_study_requires_both_parts_and_is_order_independent() -> void:
	var names := _list({"Forest": 20, "Mountain": 16, "Channel": 4, "Fireball": 4,
		"Craw Wurm": 16})
	var study := AiDeckStudy.analyze(names)
	names.reverse()
	var reversed := AiDeckStudy.analyze(names)
	assert_eq(study.plans, reversed.plans)
	assert_eq(study.synergies, reversed.synergies)
	assert_true(study.synergies.any(func(s: Dictionary) -> bool:
		return s["name"] == "life_into_x_damage"))
	var alone := AiDeckStudy.analyze(["Channel", "Forest"])
	assert_false(alone.synergies.any(func(s: Dictionary) -> bool:
		return s["name"] == "life_into_x_damage"))


func test_study_retains_no_card_objects_or_library_order() -> void:
	var study := AiDeckStudy.analyze(["Island", "Counterspell", "Island"])
	assert_eq(study.counts, {"Island": 2, "Counterspell": 1})
	assert_true(study.roles.has("Counterspell"))
	assert_eq(study.unknown_count, 0)


func test_color_demands_sources_and_roles_are_counted_per_registered_copy() -> void:
	var study := AiDeckStudy.analyze(["Tundra", "Island", "Counterspell", "Counterspell",
		"Serra Angel", "Winter Orb", "Sol Ring"])
	assert_eq(study.color_demand[Mtg.ManaColor.U], 4)
	assert_eq(study.color_demand[Mtg.ManaColor.W], 2)
	assert_eq(study.color_sources[Mtg.ManaColor.U], 2)
	assert_eq(study.color_sources[Mtg.ManaColor.W], 1)
	assert_eq(study.role_counts["counter"], 2)
	assert_eq(study.role_counts["land_denial"], 1)
	assert_true(study.synergies.any(func(s: Dictionary) -> bool:
		return s["name"] == "land_denial_with_artifact_mana"))


func test_strategy_and_visible_combo_partner_change_useful_card_preferences() -> void:
	var study := AiDeckStudy.analyze(["Channel", "Fireball", "Forest", "Mountain",
		"Stone Rain", "Sol Ring"])
	assert_gt(study.cast_bonus("Fireball", ["Channel"]),
		study.cast_bonus("Fireball", []))
	var pilot := AiPlayer.new(0, AiProfile.wizard())
	g.players[0].deck_names.assign(["Channel", "Fireball", "Forest", "Mountain"])
	g.set_agent(0, pilot)
	give_hand(0, "Channel")
	var fireball := give_hand(0, "Fireball")
	assert_gt(pilot._study_cast_bonus(g, fireball, 3.0), 0.0)
	assert_eq(pilot._study_cast_bonus(g, fireball, 0.0), 0.0)
	assert_eq(pilot._study_cast_bonus(g, fireball, 900.0), 0.0)
	pilot.profile.studies_deck = false
	assert_eq(pilot._study_cast_bonus(g, fireball, 3.0), 0.0)


func test_study_presets_are_monotone_and_have_an_explicit_null() -> void:
	var profiles := [AiProfile.apprentice(), AiProfile.magician(),
		AiProfile.sorcerer(), AiProfile.wizard()]
	var budgets := [0, 0, 64, 96]
	for i in profiles.size():
		assert_eq(profiles[i].studies_deck, i >= 2)
		assert_eq(profiles[i].studies_combat, i >= 2)
		assert_eq(profiles[i].action_search_nodes, budgets[i])
		assert_eq(profiles[i].apply_overrides(
			"studies_deck=off,studies_combat=off,action_search_nodes=0"), "")
		assert_false(profiles[i].studies_deck)
		assert_false(profiles[i].studies_combat)
		assert_eq(profiles[i].action_search_nodes, 0)
