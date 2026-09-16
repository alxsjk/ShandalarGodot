extends GameTest

func before_each() -> void:
	CardPacks.set_enabled("pack-5", true)
	super()
	advance_to_step(Mtg.Step.MAIN1)
func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-5", false)
func cast(name: String, targets: Array = []) -> CardInstance:
	var c := give_hand(0, name)
	for color in Mtg.WUBRG: add_mana(0, color, 12)
	assert_ok(g.cast_spell(0, c, targets))
	resolve_stack()
	return c
func blocks(a: CardInstance, b: CardInstance) -> void:
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [a.id]))
	resolve_stack()
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {b.id: a.id}))
	resolve_stack()

func test_bestial_fury_triggers_once_and_gift_uses_blockers_boundary() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	var wall := put_battlefield(1, "Wall of Stone")
	cast("Bestial Fury", [TargetRef.card(bear)])
	cast("Gift of the Woods", [TargetRef.card(bear)])
	blocks(bear, wall)
	assert_eq(bear.cur_power, 6)
	assert_eq(bear.cur_toughness, 5)
	assert_true(bear.has_keyword(Mtg.Keyword.TRAMPLE))
	assert_eq(g.players[0].life, 21)

func test_awesome_presence_does_not_force_payment_for_elvish_bard_lure() -> void:
	var bard := put_battlefield(0, "Elvish Bard")
	put_battlefield(1, "Grizzly Bears")
	cast("Awesome Presence", [TargetRef.card(bard)])
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [bard.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	add_mana(1, Mtg.ManaColor.C, 3)
	assert_ok(g.declare_blockers(1, {}))
	assert_eq(g.players[1].mana_pool.total(), 3)

func test_sworn_defender_uses_live_other_stats_not_its_own_stats() -> void:
	var defender := put_battlefield(0, "Sworn Defender")
	var wall := put_battlefield(1, "Wall of Stone")
	blocks(defender, wall)
	add_mana(0, Mtg.ManaColor.C)
	assert_ok(g.activate_ability(0, defender, 0, [TargetRef.card(wall)]))
	resolve_stack()
	assert_eq(defender.cur_power, 7)
	assert_eq(defender.cur_toughness, 1)

func test_unblocked_keeper_loses_life_instead_of_dealing_its_power() -> void:
	var keeper := put_battlefield(0, "Keeper of Tresserhorn")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [keeper.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {}))
	resolve_stack()
	assert_eq(g.players[1].life, 18)
	advance_to_step(Mtg.Step.COMBAT_END)
	assert_eq(g.players[1].life, 18)

func test_swamp_mosquito_poison_and_home_guard_deserter() -> void:
	var mosquito := put_battlefield(0, "Swamp Mosquito")
	var guard := put_battlefield(0, "Kjeldoran Home Guard")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [mosquito.id, guard.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {}))
	resolve_stack()
	assert_eq(g.players[1].poison, 1)
	advance_to_step(Mtg.Step.COMBAT_END)
	resolve_stack()
	assert_eq(int(guard.counters.get("-0/-1", 0)), 1)
	assert_eq(g.players[0].creatures().size(), 3)

func test_starfish_counts_actual_regenerations_not_shields() -> void:
	var fish := put_battlefield(0, "Spiny Starfish")
	add_mana(0, Mtg.ManaColor.U, 3)
	for n in 3:
		assert_ok(g.activate_ability(0, fish, 0))
		resolve_stack()
	for n in 2: g.destroy(fish)
	assert_eq(fish.regenerations_this_turn, 2)
	advance_to_step(Mtg.Step.END)
	resolve_stack()
	assert_eq(g.players[0].creatures().size(), 3)

func test_sphere_uses_departure_counter_count_and_opponent_receives_orb() -> void:
	var sphere := put_battlefield(0, "Phantasmal Sphere")
	g.add_counters(sphere, "+1/+1", 3)
	g.return_to_hand(sphere)
	resolve_stack()
	assert_eq(g.players[1].creatures().size(), 1)
	var orb := g.players[1].creatures()[0]
	assert_eq(orb.cur_power, 3)
	assert_eq(orb.cur_toughness, 3)
	assert_true(orb.has_keyword(Mtg.Keyword.FLYING))

func test_skycaptain_unpaid_wages_transfer_control_and_clear_counters() -> void:
	var captain := put_battlefield(0, "Rogue Skycaptain")
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 0})
	resolve_stack()
	assert_eq(captain.controller_id, 1)
	assert_eq(int(captain.counters.get("wage", 0)), 0)

func test_thought_lash_failed_upkeep_exiles_remainder_face_up() -> void:
	var lash := put_battlefield(0, "Thought Lash")
	g.add_counters(lash, "age", 40)
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 0})
	resolve_stack()
	assert_eq(lash.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[0].library.size(), 0)
	for card in g.players[0].exile: assert_false(card.face_down)

func test_royal_decree_checks_tapped_object_controller() -> void:
	put_battlefield(0, "Royal Decree")
	var mountain := put_battlefield(1, "Mountain")
	assert_ok(g.tap_for_mana(1, mountain))
	resolve_stack()
	assert_eq(g.players[0].life, 20)
	assert_eq(g.players[1].life, 19)

func test_lord_of_tresserhorn_ai_sacrifices_two_small_creatures() -> void:
	var ai := AiPlayer.new(0, AiProfile.wizard())
	g.set_agent(0, ai)
	var lord := put_battlefield(0, "Lord of Tresserhorn")
	var a := put_battlefield(0, "Llanowar Elves")
	var b := put_battlefield(0, "Llanowar Elves")
	resolve_stack()
	assert_eq(lord.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(a.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(b.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[0].life, 18)
	assert_eq(g.players[1].hand.size(), 2)

func test_scars_counts_prevented_damage_not_shield_size() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	cast("Scars of the Veteran", [TargetRef.card(bear)])
	g.deal_damage(give_hand(1, "Lightning Bolt"), TargetRef.card(bear), 3)
	assert_eq(bear.damage, 0)
	advance_to_step(Mtg.Step.END)
	resolve_stack()
	assert_eq(int(bear.counters.get("+0/+1", 0)), 3)

func test_martyrdom_interacts_with_protection_on_new_recipient() -> void:
	var knight := put_battlefield(0, "White Knight")
	cast("Martyrdom", [TargetRef.card(knight)])
	assert_ok(g.activate_ability(0, knight, 0, [TargetRef.player(0)]))
	resolve_stack()
	g.deal_damage(give_hand(1, "Drain Life"), TargetRef.player(0), 2)
	assert_eq(g.players[0].life, 19)
	assert_eq(knight.damage, 0)

class PreventFirst extends DecisionAgent:
	func answer_option(_g: MtgGame, _pid: int, _prompt: String, options: Array[String], hint: int) -> int:
		for index in options.size():
			if options[index].contains("prevented damage"): return index
		return hint

func test_player_can_choose_prevention_before_martyrdom_redirect() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	cast("Martyrdom", [TargetRef.card(bear)])
	assert_ok(g.activate_ability(0, bear, 0, [TargetRef.player(0)]))
	resolve_stack()
	g.players[0].damage_prevention = 3
	g.set_agent(0, PreventFirst.new())
	g.deal_damage(give_hand(1, "Lightning Bolt"), TargetRef.player(0), 3)
	assert_eq(g.players[0].life, 20)
	assert_eq(bear.damage, 0)
	assert_eq(g.players[0].damage_replacements.size(), 1)
