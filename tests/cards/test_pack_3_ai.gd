extends GameTest

func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()

func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)

func pilot() -> AiPlayer:
	var ai := AiPlayer.new(0, AiProfile.wizard())
	ai.profile.develops_late = false
	g.agents[0] = ai
	return ai

func test_ai_uses_melee_to_force_a_winning_fight() -> void:
	var giant := put_battlefield(0, "Scaled Wurm")
	var enemy := put_battlefield(1, "Serra Angel")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [giant.id]))
	give_hand(0, "Melee")
	add_mana(0, Mtg.ManaColor.R, 5)
	var ai := pilot()
	assert_eq(load("res://engine/ai/ice_age_tactics.gd").respond(g, ai), "cast Melee")
	resolve_stack()
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_eq(ai.act(g), "chose opposing blockers with Melee")
	assert_eq(g.combat.blocks.get(enemy.id, -1), giant.id)
	assert_false(g.awaiting_blockers)

func test_ai_changes_jarkeld_blocks_to_save_a_creature_and_kill_an_enemy() -> void:
	var general := put_battlefield(0, "General Jarkeld")
	var bear := put_battlefield(0, "Grizzly Bears")
	var giant := put_battlefield(0, "Hill Giant")
	var enemy := put_battlefield(1, "Hill Giant")
	var wall := put_battlefield(1, "Wall of Stone")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [bear.id, giant.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {enemy.id: bear.id, wall.id: giant.id}))
	var ai := pilot()
	var choice: Dictionary = load("res://engine/ai/ice_age_tactics.gd").option(g, ai, general, 0, "COMBAT")
	assert_false(choice.is_empty())
	assert_ok(g.activate_ability(0, general, 0, choice.targets))
	resolve_stack()
	assert_eq(g.combat.blocks[wall.id], bear.id)
	assert_eq(g.combat.blocks[enemy.id], giant.id)

func test_ai_does_not_enchant_its_own_creature_with_errant_minion() -> void:
	put_battlefield(0, "Grizzly Bears")
	var enemy := put_battlefield(1, "Hill Giant")
	advance_to_step(Mtg.Step.MAIN1)
	give_hand(0, "Errant Minion")
	add_mana(0, Mtg.ManaColor.U, 3)
	assert_eq(pilot()._try_cast_best(g), "cast Errant Minion")
	assert_eq(g.stack.back().targets[0].instance_id, enemy.id)

func test_ai_casts_and_keeps_hecatomb_with_four_small_bodies_and_swamps() -> void:
	for _n in 4: put_battlefield(0, "Ornithopter")
	for _n in 4: put_battlefield(0, "Swamp")
	advance_to_step(Mtg.Step.MAIN1)
	var hecatomb := give_hand(0, "Hecatomb")
	assert_eq(pilot()._try_cast_best(g), "cast Hecatomb")
	resolve_stack()
	assert_eq(hecatomb.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(g.players[0].graveyard.size(), 4)

func test_ai_preserves_hecatomb_when_it_cannot_pay_the_entry_price() -> void:
	put_battlefield(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	var hecatomb := give_hand(0, "Hecatomb")
	add_mana(0, Mtg.ManaColor.B, 3)
	assert_eq(pilot()._try_cast_best(g), "")
	assert_eq(hecatomb.zone, Mtg.Zone.HAND)

func test_ai_uses_merieke_to_steal_the_enemy_creature() -> void:
	var merieke := put_battlefield(0, "Merieke Ri Berit")
	var enemy := put_battlefield(1, "Serra Angel")
	advance_to_step(Mtg.Step.MAIN1)
	assert_eq(pilot()._try_activate(g), "activated Merieke Ri Berit")
	resolve_stack()
	assert_true(merieke.tapped)
	assert_eq(enemy.controller_id, 0)

func test_ai_revives_a_white_creature_with_dreams_of_the_dead() -> void:
	put_battlefield(0, "Dreams of the Dead")
	var angel := put_battlefield(0, "Serra Angel")
	g.destroy(angel, false)
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.U, 2)
	assert_eq(pilot()._try_activate(g), "activated Dreams of the Dead")
	resolve_stack()
	assert_eq(angel.zone, Mtg.Zone.BATTLEFIELD)
	assert_true(angel.cur_exile_on_leaving)

func test_ai_crown_moves_a_hostile_aura_off_its_own_creature() -> void:
	var crown := put_battlefield(0, "Crown of the Ages")
	var mine := put_battlefield(0, "Hill Giant")
	var enemy := put_battlefield(1, "Serra Angel")
	var curse := give_hand(1, "Weakness")
	g.attach_aura_from_anywhere(curse, mine, 1)
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.C, 4)
	assert_eq(pilot()._try_activate(g), "activated Crown of the Ages")
	resolve_stack()
	assert_eq(curse.attached_to, enemy.id)
	assert_true(crown.tapped)

func test_ai_spends_finite_iceberg_counters_to_cast_an_artifact() -> void:
	var iceberg := put_battlefield(0, "Iceberg")
	g.add_counters(iceberg, "ice", 3)
	advance_to_step(Mtg.Step.MAIN1)
	var book := give_hand(0, "Jayemdae Tome")
	assert_eq(pilot()._try_cast_best(g), "", "three counters cannot pay four")
	g.add_counters(iceberg, "ice")
	assert_eq(pilot()._try_cast_best(g), "cast Jayemdae Tome")
	assert_eq(int(iceberg.counters.get("ice", 0)), 0)
	assert_eq(book.zone, Mtg.Zone.STACK)
	assert_false(iceberg.tapped)

func test_machinist_restricted_mana_can_feed_an_artifact_converter() -> void:
	var machinist := put_battlefield(0, "Soldevi Machinist")
	var prism := put_battlefield(0, "Celestial Prism")
	advance_to_step(Mtg.Step.MAIN1)
	assert_true(g.try_pay(0, ManaCost.parse("{U}")))
	assert_true(machinist.tapped)
	assert_true(prism.tapped)
	assert_eq(g.players[0].mana_pool.total(), 0)

func test_ai_stores_spare_mana_in_amulet_at_the_sink() -> void:
	var amulet := put_battlefield(0, "Jeweled Amulet")
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.G)
	assert_eq(pilot()._try_activate(g, AiPlayer.Moment.SINK), "activated Jeweled Amulet")
	resolve_stack()
	assert_eq(int(amulet.counters.get("charge", 0)), 1)

func test_ai_sizes_and_pays_ice_cauldron_x() -> void:
	var cauldron := put_battlefield(0, "Ice Cauldron")
	var bear := give_hand(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.G)
	add_mana(0, Mtg.ManaColor.C)
	var ai := pilot()
	assert_eq(ai._try_activate(g, AiPlayer.Moment.SINK), "activated Ice Cauldron")
	assert_eq(g.stack.back().x_value, 2)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.EXILE)
	g.untap_permanent(cauldron)
	assert_eq(ai._try_cast_best(g), "cast Grizzly Bears")
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)

func test_ai_retargets_chromatic_color_for_incoming_burn() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	var armor := give_hand(0, "Chromatic Armor")
	g.attach_aura_from_anywhere(armor, bear, 0)
	armor.memory["ward_color"] = Mtg.ManaColor.G
	g.recalculate()
	advance_to_step(Mtg.Step.MAIN1)
	var bolt := give_hand(1, "Lightning Bolt")
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(1, bolt, [TargetRef.card(bear)]))
	g.priority_player = 0
	add_mana(0, Mtg.ManaColor.C)
	assert_eq(pilot()._try_activate(g, AiPlayer.Moment.RESPONSE), "activated Chromatic Armor")
	resolve_stack()
	assert_eq(int(armor.memory.ward_color), Mtg.ManaColor.R)
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(bear.damage, 0)

func test_ai_uses_runed_arch_for_lethal_with_real_x_payment() -> void:
	var arch := put_battlefield(0, "Runed Arch")
	g.untap_permanent(arch)
	var bear := put_battlefield(0, "Grizzly Bears")
	put_battlefield(1, "Wall of Stone")
	advance_to_step(Mtg.Step.MAIN1)
	g.players[1].life = 2
	add_mana(0, Mtg.ManaColor.C)
	assert_eq(pilot()._try_activate(g), "activated Runed Arch")
	assert_eq(arch.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.stack.back().x_value, 1)
	resolve_stack()
	assert_true(bear.has_keyword(Mtg.Keyword.UNBLOCKABLE))

func test_ai_counter_search_includes_public_exile_permission() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var counter := give_hand(0, "Counterspell")
	g.exile_from_hand(counter)
	g.grant_exile_play(counter, 0)
	var threat := give_hand(1, "Serra Angel")
	g.active_player = 1
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.W, 5)
	assert_ok(g.cast_spell(1, threat))
	g.priority_player = 0
	add_mana(0, Mtg.ManaColor.U, 2)
	assert_ne(pilot()._try_counter(g), "")
	resolve_stack()
	assert_eq(threat.zone, Mtg.Zone.GRAVEYARD)

func test_ai_does_not_repeat_an_augury_inspection_this_turn() -> void:
	var augury := put_battlefield(0, "Elemental Augury")
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.C, 6)
	var ai := pilot()
	assert_eq(ai._try_activate(g, AiPlayer.Moment.SINK), "activated Elemental Augury")
	resolve_stack()
	assert_eq(int(augury.memory.augury_turn), g.turn_number)
	assert_eq(ai._try_activate(g, AiPlayer.Moment.SINK), "")

func test_ai_blinks_spirit_away_from_targeted_removal() -> void:
	var spirit := put_battlefield(0, "Blinking Spirit")
	advance_to_step(Mtg.Step.MAIN1)
	var terror := give_hand(1, "Terror")
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.B, 2)
	assert_ok(g.cast_spell(1, terror, [TargetRef.card(spirit)]))
	g.priority_player = 0
	assert_eq(pilot()._try_activate(g, AiPlayer.Moment.RESPONSE), "activated Blinking Spirit")
	resolve_stack()
	assert_eq(spirit.zone, Mtg.Zone.HAND)

func test_ai_does_not_repeatedly_bounce_a_safe_spirit() -> void:
	var spirit := put_battlefield(0, "Blinking Spirit")
	advance_to_step(Mtg.Step.MAIN1)
	assert_true(pilot()._ability_option(g, spirit, 0, AiPlayer.Moment.MAIN).is_empty())

func test_ai_uses_aura_pump_to_save_host_from_burn() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	var armor := give_hand(0, "Armor of Faith")
	g.attach_aura_from_anywhere(armor, bear, 0)
	advance_to_step(Mtg.Step.MAIN1)
	var bolt := give_hand(1, "Lightning Bolt")
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(1, bolt, [TargetRef.card(bear)]))
	g.priority_player = 0
	add_mana(0, Mtg.ManaColor.W)
	assert_eq(pilot()._try_activate(g, AiPlayer.Moment.RESPONSE), "activated Armor of Faith")
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(bear.damage, 3)
	assert_eq(bear.cur_toughness, 4)

func test_ai_fights_a_smaller_enemy_with_yeti() -> void:
	put_battlefield(0, "Karplusan Yeti")
	var bear := put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	assert_eq(pilot()._try_activate(g), "activated Karplusan Yeti")
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)

func test_ai_cumulative_upkeep_abandons_an_overpriced_wall() -> void:
	var wall := put_battlefield(0, "Illusionary Wall")
	assert_false(pilot().cumulative_upkeep_hint(g, 0, wall, ManaCost.parse("{20}"), 0, 0))

func test_ai_keeps_grandeur_when_losing_it_would_be_lethal() -> void:
	var grandeur := put_battlefield(0, "Illusions of Grandeur")
	resolve_stack()
	g.players[0].life = 15
	assert_true(pilot().cumulative_upkeep_hint(g, 0, grandeur, ManaCost.parse("{20}"), 0, 0))

func test_ai_never_pays_its_last_life_as_cumulative_upkeep() -> void:
	var storm := put_battlefield(0, "Energy Storm")
	g.players[0].life = 2
	assert_false(pilot().cumulative_upkeep_hint(g, 0, storm, ManaCost.parse(""), 2, 0))

func test_ai_divides_fire_covenant_among_two_enemy_creatures() -> void:
	var a := put_battlefield(1, "Air Elemental")
	var b := put_battlefield(1, "Serra Angel")
	advance_to_step(Mtg.Step.MAIN1)
	g.players[0].life = 30
	var spell := give_hand(0, "Fire Covenant")
	add_mana(0, Mtg.ManaColor.B)
	add_mana(0, Mtg.ManaColor.R)
	add_mana(0, Mtg.ManaColor.C)
	var ai := pilot()
	var choice: Dictionary = ai._plan_spell_choice(g, spell, 1)
	assert_false(choice.is_empty())
	if choice.is_empty(): return
	assert_eq(choice.x, 8)
	assert_eq(choice.targets.size(), 2)
	assert_ok(g.cast_spell(0, spell, choice.targets, choice.x))
	resolve_stack()
	assert_eq(a.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(b.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[0].life, 22)

func test_ai_does_not_cast_fire_covenant_into_energy_storm() -> void:
	put_battlefield(1, "Energy Storm")
	put_battlefield(1, "Serra Angel")
	advance_to_step(Mtg.Step.MAIN1)
	var spell := give_hand(0, "Fire Covenant")
	assert_true(preload("res://engine/ai/ice_age_tactics.gd").spell_choice(g, pilot(), spell, 10, 0).is_empty())

func test_ai_hydroblast_does_not_waste_counter_mode_on_green_spell() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var bear := give_hand(1, "Grizzly Bears")
	g.active_player = 1
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.G, 2)
	assert_ok(g.cast_spell(1, bear))
	var blast := give_hand(0, "Hydroblast")
	assert_null(pilot()._counter_spec(g, blast, TargetRef.card(bear)))

func test_ai_hydroblast_aims_at_red_permanent_not_more_valuable_white_one() -> void:
	var red := put_battlefield(1, "Orcish Artillery")
	put_battlefield(1, "Serra Angel")
	advance_to_step(Mtg.Step.MAIN1)
	var spell := give_hand(0, "Hydroblast")
	var choice: Dictionary = preload("res://engine/ai/ice_age_tactics.gd").spell_choice(g, pilot(), spell, 0, 1)
	assert_eq(choice.targets[0].instance_id, red.id)

func test_ai_sizes_mind_warp_to_hand_count() -> void:
	for _i in 3: give_hand(1, "Forest")
	var spell := give_hand(0, "Mind Warp")
	var choice: Dictionary = preload("res://engine/ai/ice_age_tactics.gd").spell_choice(g, pilot(), spell, 10, 0)
	assert_eq(choice.x, 3)

func test_ai_meteor_counts_the_extra_point_for_lethal() -> void:
	g.players[1].life = 4
	var spell := give_hand(0, "Meteor Shower")
	var choice: Dictionary = preload("res://engine/ai/ice_age_tactics.gd").spell_choice(g, pilot(), spell, 3, 0)
	assert_eq(choice.x, 3)
	assert_eq(choice.targets[0].player_id, 1)
