extends GameTest
const D := preload("res://engine/core/combat_declaration.gd")

func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()
func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)

func enchant(name: String, body: CardInstance) -> CardInstance:
	advance_to_step(Mtg.Step.MAIN1)
	var aura := give_hand(0, name)
	for color in Mtg.WUBRG: add_mana(0, color, 5)
	assert_ok(g.cast_spell(0, aura, [TargetRef.card(body)]))
	resolve_stack()
	return aura

func test_errantry_requires_a_single_attacker_and_adds_three_power() -> void:
	var a := put_battlefield(0, "Grizzly Bears")
	var b := put_battlefield(0, "Grizzly Bears")
	enchant("Errantry", a)
	assert_eq(a.cur_power, 5)
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_refused(g.declare_attackers(0, [a.id, b.id]))
	assert_false(a.tapped)
	assert_ok(g.declare_attackers(0, [a.id]))

func test_conflicting_must_attack_alone_requirements_do_not_deadlock() -> void:
	var a := put_battlefield(0, "Grizzly Bears")
	var b := put_battlefield(0, "Grizzly Bears")
	enchant("Errantry", a)
	a.must_attack_this_turn = true
	b.must_attack_this_turn = true
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_refused(g.declare_attackers(0, []))
	assert_ok(g.declare_attackers(0, [a.id]))

func test_conscripts_requires_three_actual_attackers_and_ai_repairs_it() -> void:
	var a := put_battlefield(0, "Orcish Conscripts")
	var b := put_battlefield(0, "Grizzly Bears")
	var c := put_battlefield(0, "Grizzly Bears")
	a.must_attack_this_turn = true
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_refused(g.declare_attackers(0, [a.id, b.id]))
	var army := D.repair_attacks(g, 0, [a.id])
	assert_eq(army.size(), 3)
	assert_true(army.has(c.id))
	assert_ok(g.declare_attackers(0, army))

func test_conscripts_with_no_possible_group_can_stay_home() -> void:
	var a := put_battlefield(0, "Orcish Conscripts")
	a.must_attack_this_turn = true
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ne(CombatState.attack_illegality(g, a, 1), "")
	assert_ok(g.declare_attackers(0, []))

func test_conscripts_counts_other_blocking_creatures_not_blocks() -> void:
	var a := put_battlefield(0, "Grizzly Bears")
	var c := put_battlefield(1, "Orcish Conscripts")
	var b := put_battlefield(1, "Grizzly Bears")
	var d := put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [a.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_refused(g.declare_blockers(1, {c.id: a.id, b.id: a.id}))
	assert_ok(g.declare_blockers(1, {c.id: a.id, b.id: a.id, d.id: a.id}))

func test_two_hipparions_cannot_spend_the_same_blocking_mana() -> void:
	var a := put_battlefield(0, "Hill Giant")
	var h1 := put_battlefield(1, "Hipparion")
	var h2 := put_battlefield(1, "Hipparion")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [a.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	add_mana(1, Mtg.ManaColor.C)
	assert_refused(g.declare_blockers(1, {h1.id: a.id, h2.id: a.id}))
	assert_eq(g.players[1].mana_pool.total(), 1)
	assert_ok(g.declare_blockers(1, {h1.id: a.id}))
	assert_eq(g.players[1].mana_pool.total(), 0)

func test_land_attack_taxes_are_aggregated_before_any_cost_is_paid() -> void:
	put_battlefield(1, "Flooded Woodlands")
	var a := put_battlefield(0, "Grizzly Bears")
	var b := put_battlefield(0, "Grizzly Bears")
	var land := put_battlefield(0, "Forest")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_refused(g.declare_attackers(0, [a.id, b.id]))
	assert_eq(land.zone, Mtg.Zone.BATTLEFIELD)
	assert_false(a.tapped)
	assert_ok(g.declare_attackers(0, [a.id]))
	assert_eq(land.zone, Mtg.Zone.GRAVEYARD)

func test_two_reclamations_charge_two_lands_but_do_not_force_a_paid_attack() -> void:
	put_battlefield(1, "Reclamation")
	put_battlefield(1, "Reclamation")
	var a := put_battlefield(0, "Black Knight")
	a.must_attack_this_turn = true
	put_battlefield(0, "Swamp")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_refused(g.declare_attackers(0, [a.id]))
	assert_ok(g.declare_attackers(0, []))

func test_duplicate_attackers_are_rejected_without_tapping() -> void:
	var a := put_battlefield(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_refused(g.declare_attackers(0, [a.id, a.id]))
	assert_false(a.tapped)

func test_jarkeld_exchanges_blocks_once_not_once_per_target() -> void:
	var general := put_battlefield(0, "General Jarkeld")
	var a := put_battlefield(0, "Grizzly Bears")
	var b := put_battlefield(0, "Hill Giant")
	var c := put_battlefield(1, "Grizzly Bears")
	var d := put_battlefield(1, "Hill Giant")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [a.id, b.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {c.id: a.id, d.id: b.id}))
	assert_ok(g.activate_ability(0, general, 0, [TargetRef.card(a), TargetRef.card(b)]))
	resolve_stack()
	assert_eq(g.combat.blocks[c.id], b.id)
	assert_eq(g.combat.blocks[d.id], a.id)

func test_jarkeld_checks_every_new_block_against_live_evasion() -> void:
	var general := put_battlefield(0, "General Jarkeld")
	var a := put_battlefield(0, "Grizzly Bears")
	var b := put_battlefield(0, "Serra Angel")
	var c := put_battlefield(1, "Grizzly Bears")
	var d := put_battlefield(1, "Serra Angel")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [a.id, b.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {c.id: a.id, d.id: b.id}))
	assert_ok(g.activate_ability(0, general, 0, [TargetRef.card(a), TargetRef.card(b)]))
	resolve_stack()
	assert_eq(g.combat.blocks[c.id], a.id)
	assert_eq(g.combat.blocks[d.id], b.id)

func test_jarkeld_cannot_exchange_a_menace_pair_for_only_one_blocker() -> void:
	var general := put_battlefield(0, "General Jarkeld")
	var a := put_battlefield(0, "Grizzly Bears")
	var b := put_battlefield(0, "Hill Giant")
	var c := put_battlefield(1, "Grizzly Bears")
	var d := put_battlefield(1, "Hill Giant")
	var e := put_battlefield(1, "Grizzly Bears")
	enchant("Imposing Visage", a)
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [a.id, b.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {c.id: a.id, e.id: a.id, d.id: b.id}))
	assert_ok(g.activate_ability(0, general, 0, [TargetRef.card(a), TargetRef.card(b)]))
	resolve_stack()
	assert_eq(g.combat.blocks[c.id], a.id)
	assert_eq(g.combat.blocks[d.id], b.id)
	assert_eq(g.combat.blocks[e.id], a.id)

func test_gaze_creates_a_targeted_trigger_for_each_unblocked_attacker() -> void:
	var a := put_battlefield(0, "Hill Giant")
	var enemy := put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	var gaze := give_hand(0, "Gaze of Pain")
	add_mana(0, Mtg.ManaColor.B, 2)
	assert_ok(g.cast_spell(0, gaze))
	resolve_stack()
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [a.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {}))
	assert_eq(g.stack.size(), 1)
	assert_eq(g.stack[0].targets[0].instance_id, enemy.id)
	resolve_stack()
	assert_eq(enemy.zone, Mtg.Zone.GRAVEYARD)
	assert_true(a.cur_assigns_no_combat_damage)

func test_gaze_remembers_power_at_departure_not_at_trigger_or_after_blink() -> void:
	var a := put_battlefield(0, "Hill Giant")
	var enemy := put_battlefield(1, "Craw Wurm")
	advance_to_step(Mtg.Step.MAIN1)
	var gaze := give_hand(0, "Gaze of Pain")
	add_mana(0, Mtg.ManaColor.B, 2)
	assert_ok(g.cast_spell(0, gaze))
	resolve_stack()
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [a.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {}))
	var stamp := a.layer_timestamp
	g.add_counters(a, "+1/+1", 2)
	g.return_to_hand(a)
	g.put_from_hand_into_play(a, 0)
	assert_ne(a.layer_timestamp, stamp)
	assert_eq(a.cur_power, 3)
	resolve_stack()
	assert_eq(enemy.zone, Mtg.Zone.GRAVEYARD, "last-known five power kills the 6/4 Wurm")
	assert_false(a.cur_assigns_no_combat_damage, "the returned Giant is a new object")

func test_melee_gives_attacker_the_choice_and_retreats_only_unblocked() -> void:
	var a := put_battlefield(0, "Hill Giant")
	var b := put_battlefield(0, "Grizzly Bears")
	var c := put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [a.id, b.id]))
	var spell := give_hand(0, "Melee")
	add_mana(0, Mtg.ManaColor.R, 5)
	assert_ok(g.cast_spell(0, spell))
	resolve_stack()
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_eq(g.block_chooser(), 0)
	assert_refused(g.declare_blockers(1, {}))
	assert_ok(g.declare_blockers(0, {c.id: a.id}))
	assert_true(g.combat.attackers.has(b.id), "retreat is an answerable trigger")
	resolve_stack()
	assert_false(b.tapped)
	assert_false(g.combat.attackers.has(b.id))
	assert_true(g.combat.attackers.has(a.id))
	g.continuous.expire_end_of_combat()
	g.recalculate()
	assert_eq(g.block_chooser(), 1)
	assert_true(g.melee_active_effects.is_empty())

func test_melee_cannot_force_the_defender_to_pay_a_block_cost() -> void:
	var a := put_battlefield(0, "Hill Giant")
	var b := put_battlefield(1, "Hipparion")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [a.id]))
	var spell := give_hand(0, "Melee")
	add_mana(0, Mtg.ManaColor.R, 5)
	assert_ok(g.cast_spell(0, spell))
	resolve_stack()
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	add_mana(1, Mtg.ManaColor.C)
	assert_refused(g.declare_blockers(0, {b.id: a.id}))
	assert_eq(g.players[1].mana_pool.total(), 1)
	assert_ok(g.declare_blockers(0, {}))

func test_drought_counts_printed_black_symbols_not_x_or_actual_mana() -> void:
	put_battlefield(1, "Drought")
	var one := put_battlefield(0, "Swamp")
	var two := put_battlefield(0, "Swamp")
	advance_to_step(Mtg.Step.MAIN1)
	var burn := give_hand(0, "Soul Burn")
	add_mana(0, Mtg.ManaColor.B, 6)
	assert_ok(g.cast_spell(0, burn, [TargetRef.player(1)], 3))
	assert_eq(g.players[0].graveyard.size(), 1)
	assert_true(one.zone != two.zone)
	resolve_stack()
	assert_eq(g.players[1].life, 17)

func test_drought_refusal_preserves_mana_and_stack_and_swamps() -> void:
	put_battlefield(1, "Drought")
	var land := put_battlefield(0, "Swamp")
	advance_to_step(Mtg.Step.MAIN1)
	var knight := give_hand(0, "Black Knight")
	add_mana(0, Mtg.ManaColor.B, 2)
	assert_refused(g.cast_spell(0, knight))
	assert_eq(land.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(g.players[0].mana_pool.total(), 2)
	assert_true(g.stack.is_empty())
	assert_eq(knight.zone, Mtg.Zone.HAND)

func test_drought_is_paid_on_black_activated_ability_but_not_upkeep() -> void:
	var drought := put_battlefield(1, "Drought")
	var knight := put_battlefield(0, "Knight of Stromgald")
	var swamp := put_battlefield(0, "Swamp")
	advance_to_step(Mtg.Step.MAIN1)
	add_mana(0, Mtg.ManaColor.B)
	assert_ok(g.activate_ability(0, knight, 0))
	assert_eq(swamp.zone, Mtg.Zone.GRAVEYARD)
	resolve_stack()
	assert_true(knight.has_keyword(Mtg.Keyword.FIRST_STRIKE))
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 1})
	resolve_stack()
	assert_eq(drought.zone, Mtg.Zone.GRAVEYARD)

func test_drought_reserves_distinct_bodies_for_other_sacrifices() -> void:
	put_battlefield(1, "Drought")
	var only_body := put_battlefield(0, "Mishra's Factory")
	# A live Swamp creature can pay either part, never both.
	only_body.become_basic_land_type("swamp", Mtg.ManaColor.B)
	var pool: Array = [only_body]
	assert_false(g.BLACK_SYMBOL_COST.feasible(pool, 1, [{"bodies": pool, "count": 1}]))
	var other := put_battlefield(0, "Grizzly Bears")
	assert_true(g.BLACK_SYMBOL_COST.feasible(pool, 1, [{"bodies": [only_body, other], "count": 1}]))

class PayOne extends DecisionAgent:
	func answer_option(_g: MtgGame, _pid: int, prompt: String, options: Array[String], hint: int) -> int:
		return 1 if prompt.begins_with("Errant Minion:") and options.size() > 1 else hint

func test_errant_minion_pays_one_to_prevent_one_not_all_damage() -> void:
	var body := put_battlefield(1, "Grizzly Bears")
	enchant("Errant Minion", body)
	g.agents[1] = PayOne.new()
	add_mana(1, Mtg.ManaColor.C, 3)
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 1})
	resolve_stack()
	assert_eq(g.players[1].life, 19)
	assert_eq(g.players[1].mana_pool.total(), 2)

func test_errant_minion_prevention_does_not_shield_later_damage() -> void:
	var body := put_battlefield(1, "Grizzly Bears")
	var aura := enchant("Errant Minion", body)
	add_mana(1, Mtg.ManaColor.C, 2)
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 1})
	resolve_stack()
	assert_eq(g.players[1].life, 20)
	g.deal_damage(aura, TargetRef.player(1), 2)
	assert_eq(g.players[1].life, 18)

func test_local_prevention_and_damage_rewind_together() -> void:
	var body := put_battlefield(0, "Hill Giant")
	var mark := g.make_mark()
	g.deal_damage(body, TargetRef.player(1), 3, false, Callable(), false, 2)
	assert_eq(g.players[1].life, 19)
	g.unmake_to(mark)
	assert_eq(g.players[1].life, 20)
