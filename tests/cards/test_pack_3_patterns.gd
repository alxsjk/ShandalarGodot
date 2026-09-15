extends GameTest

class Always extends DecisionAgent:
	func answer_yes_no(_g: MtgGame, _pid: int, _prompt: String, _hint: bool) -> bool: return true

func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()
	advance_to_step(Mtg.Step.MAIN1)
func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)

func test_offering_sacrifices_before_resolution_and_uses_mana_value() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	var spell := give_hand(0, "Burnt Offering")
	add_mana(0, Mtg.ManaColor.B)
	assert_ok(g.cast_spell(0, spell))
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
	resolve_stack()
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.B), 2)

func test_augury_keeps_exact_three_cards_in_library_without_drawing() -> void:
	var augury := put_battlefield(0, "Elemental Augury")
	var before := g.players[1].library.size()
	var top: Array = load("res://cards/sets/ice/_patterns.gd").top(g, 1, 3)
	add_mana(0, Mtg.ManaColor.C, 3)
	assert_ok(g.activate_ability(0, augury, 0, [TargetRef.player(1)]))
	resolve_stack()
	assert_eq(g.players[1].library.size(), before)
	for i in load("res://cards/sets/ice/_patterns.gd").top(g, 1, 3): assert_has(top, i)
	assert_true(g.players[1].hand.is_empty())

func test_librarian_exiles_four_distinct_cards_and_keeps_other_four() -> void:
	var librarian := put_battlefield(0, "Orcish Librarian")
	var before := g.players[0].library.size()
	var top: Array = load("res://cards/sets/ice/_patterns.gd").top(g, 0, 8)
	add_mana(0, Mtg.ManaColor.R)
	assert_ok(g.activate_ability(0, librarian, 0))
	resolve_stack()
	assert_eq(g.players[0].exile.size(), 4)
	assert_eq(g.players[0].library.size(), before - 4)
	for i in g.players[0].exile:
		assert_has(top, i)
		assert_false(i.face_down)
	for i in load("res://cards/sets/ice/_patterns.gd").top(g, 0, 4): assert_has(top, i)

func test_arcanix_miss_mills_and_deals_damage_without_drawing() -> void:
	var arcanix := put_battlefield(0, "Vexing Arcanix")
	g.players[1].deck_names.clear()
	var before := g.players[1].library.size()
	add_mana(0, Mtg.ManaColor.C, 3)
	assert_ok(g.activate_ability(0, arcanix, 0, [TargetRef.player(1)]))
	resolve_stack()
	assert_eq(g.players[1].library.size(), before - 1)
	assert_eq(g.players[1].life, 18)
	assert_true(g.players[1].drawn_this_turn.is_empty())

func test_hecatomb_can_pay_with_exact_four_and_taps_swamps_as_cost() -> void:
	for _n in 4: put_battlefield(0, "Grizzly Bears")
	g.agents[0] = Always.new()
	var hecatomb := put_battlefield(0, "Hecatomb")
	resolve_stack()
	assert_eq(hecatomb.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(g.players[0].graveyard.size(), 4)
	var swamp := put_battlefield(0, "Swamp")
	assert_ok(g.activate_ability(0, hecatomb, 0, [TargetRef.player(1)]))
	assert_true(swamp.tapped)
	resolve_stack()
	assert_eq(g.players[1].life, 19)

func test_farmer_type_lasts_past_cleanup_but_not_the_next_untap() -> void:
	var farmer := put_battlefield(0, "Orcish Farmer")
	var island := put_battlefield(1, "Snow-Covered Island")
	assert_ok(g.activate_ability(0, farmer, 0, [TargetRef.card(island)]))
	resolve_stack()
	assert_true(island.has_subtype("swamp"))
	assert_false(island.has_subtype("island"))
	assert_ne(island.cur_supertypes & Mtg.Supertype.SNOW, 0)
	g.continuous.expire_until_eot()
	g.recalculate()
	assert_true(island.has_subtype("swamp"))
	g.continuous.expire_untap_of(0)
	g.recalculate()
	assert_true(island.has_subtype("swamp"))
	g.continuous.expire_untap_of(1)
	g.recalculate()
	assert_true(island.has_subtype("island"))

func test_chaos_lord_attack_haste_is_not_tap_haste_and_checks_actual_entry_turn() -> void:
	var lord := put_battlefield(0, "Chaos Lord")
	assert_false(lord.cur_attacks_as_if_hasty)
	g.turn_number += 1
	g.change_control(lord, 1)
	assert_true(lord.cur_attacks_as_if_hasty)
	assert_false(lord.has_keyword(Mtg.Keyword.HASTE))
	g.return_to_hand(lord)
	g.put_from_hand_into_play(lord, 1)
	assert_false(lord.cur_attacks_as_if_hasty)

func test_chaos_moon_odd_bonus_outlives_moon_and_only_pumps_present_creatures() -> void:
	var moon := put_battlefield(0, "Chaos Moon")
	var bear := put_battlefield(0, "Balduvian Barbarians")
	var mountain := put_battlefield(0, "Mountain")
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 0})
	resolve_stack()
	assert_eq(bear.cur_power, 4)
	g.return_to_hand(moon)
	var late := put_battlefield(0, "Balduvian Barbarians")
	assert_eq(late.cur_power, 3)
	assert_ok(g.tap_for_mana(0, mountain, 0))
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.R), 2)

func test_call_to_arms_tie_triggers_sacrifice() -> void:
	put_battlefield(1, "Grizzly Bears")
	var white := put_battlefield(0, "Savannah Lions")
	var arms := put_battlefield(0, "Call to Arms")
	assert_eq(int(arms.memory.get("arms_color", -1)), Mtg.ManaColor.G)
	assert_false(load("res://cards/sets/ice/_patterns.gd")._arms_fails(g, arms, null))
	assert_eq(white.cur_power, 3)
	put_battlefield(1, "Merfolk of the Pearl Trident")
	g.check_state_based_actions() # setup helpers bypass priority/SBA publication
	assert_eq(white.cur_power, 2)
	resolve_stack()
	assert_eq(arms.zone, Mtg.Zone.GRAVEYARD)

func test_ghostly_flame_changes_damage_colors_but_not_targeting_or_spell_colors() -> void:
	var flame := put_battlefield(0, "Ghostly Flame")
	var knight := put_battlefield(1, "White Knight")
	var source := put_battlefield(0, "Black Knight")
	assert_eq(g.damage_source_colors(source), 0)
	assert_eq(source.cur_colors, Mtg.ManaColor.B)
	var terror := give_hand(0, "Terror")
	add_mana(0, Mtg.ManaColor.B, 2)
	assert_refused(g.cast_spell(0, terror, [TargetRef.card(knight)]))
	g.deal_damage(source, TargetRef.card(knight), 1)
	assert_eq(knight.damage, 1)
	g.return_to_hand(flame)
	g.deal_damage(source, TargetRef.card(knight), 1)
	assert_eq(knight.damage, 1)

func test_ghostly_flame_prevents_red_cop_naming_and_justice_trigger() -> void:
	put_battlefield(0, "Ghostly Flame")
	put_battlefield(0, "Justice")
	var cop := put_battlefield(1, "Circle of Protection: Red")
	var source := put_battlefield(0, "Balduvian Barbarians")
	var shield := PreventDamageShieldEffect.new(Mtg.ManaColor.R)
	shield.resolve(g, cop, 1, null)
	assert_true(g.players[1].prevention_shield_filters.is_empty())
	g.deal_damage(source, TargetRef.player(1), 2)
	assert_eq(g.players[1].life, 18)
	assert_true(g.stack.is_empty())

func test_oath_responds_to_life_loss_and_discard_or_sacrifice_per_point() -> void:
	var oath := put_battlefield(0, "Oath of Lim-Dûl")
	var card := give_hand(0, "Island")
	var bear := put_battlefield(0, "Grizzly Bears")
	g.adjust_life(0, -2)
	assert_eq(g.stack.size(), 1)
	resolve_stack()
	assert_eq(card.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(oath.zone, Mtg.Zone.BATTLEFIELD)

func test_oath_responds_to_actual_damage_not_prevented_damage_or_life_gain() -> void:
	put_battlefield(0, "Oath of Lim-Dûl")
	var source := put_battlefield(1, "Grizzly Bears")
	g.adjust_life(0, 2)
	assert_true(g.stack.is_empty())
	g.players[0].damage_prevention = 2
	g.deal_damage(source, TargetRef.player(0), 2)
	assert_true(g.stack.is_empty())
	g.deal_damage(source, TargetRef.player(0), 1)
	assert_eq(g.stack.size(), 1)
	resolve_stack()
