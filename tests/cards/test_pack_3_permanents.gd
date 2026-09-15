extends GameTest

func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()

func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)

func test_breath_grants_each_green_creature_its_own_cumulative_trigger() -> void:
	put_battlefield(0, "Breath of Dreams")
	var a := put_battlefield(1, "Grizzly Bears")
	var b := put_battlefield(1, "Grizzly Bears")
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 1})
	assert_eq(g.stack.size(), 2)
	add_mana(1, Mtg.ManaColor.C, 2)
	resolve_stack()
	assert_eq(int(a.counters.get("age", 0)), 1)
	assert_eq(int(b.counters.get("age", 0)), 1)
	assert_eq(g.players[1].mana_pool.total(), 0)

func test_musician_grants_one_upkeep_but_adds_multiple_counters() -> void:
	var musician := put_battlefield(0, "Musician")
	var bear := put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	for _i in 2:
		assert_ok(g.activate_ability(0, musician, 0, [TargetRef.card(bear)]))
		resolve_stack()
		g.untap_permanent(musician)
	assert_eq(int(bear.counters.get("music", 0)), 2)
	assert_eq(bear.cur_triggered_abilities.size(), 1)
	g.sacrifice_permanent(musician)
	g.dispatch_event(Mtg.EventType.UPKEEP_START, {"player": 1})
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)

func test_mole_worms_lock_ends_permanently_after_untap_retap() -> void:
	var worms := put_battlefield(0, "Mole Worms")
	var land := put_battlefield(1, "Island")
	advance_to_step(Mtg.Step.MAIN1)
	assert_ok(g.activate_ability(0, worms, 0, [TargetRef.card(land)]))
	resolve_stack()
	assert_true(land.tapped)
	assert_true(land.cur_skips_untap)
	g.untap_permanent(worms)
	g.tap_permanent(worms)
	assert_false(land.cur_skips_untap)

func test_mole_worms_untapped_before_resolution_taps_but_does_not_lock() -> void:
	var worms := put_battlefield(0, "Mole Worms")
	var land := put_battlefield(1, "Island")
	advance_to_step(Mtg.Step.MAIN1)
	assert_ok(g.activate_ability(0, worms, 0, [TargetRef.card(land)]))
	g.untap_permanent(worms)
	g.tap_permanent(worms)
	resolve_stack()
	assert_true(land.tapped)
	assert_false(land.cur_skips_untap)

func test_grandeur_enter_and_leave_follow_the_trigger_controller() -> void:
	var grandeur := put_battlefield(0, "Illusions of Grandeur")
	g.change_control(grandeur, 1)
	resolve_stack()
	assert_eq(g.players[0].life, 40)
	g.players[1].life = 40
	g.return_to_hand(grandeur)
	resolve_stack()
	assert_eq(g.players[1].life, 20)

func test_hourglass_bonus_tracks_removing_counters_and_any_player_can_pay() -> void:
	var glass := put_battlefield(0, "Infinite Hourglass")
	var a := put_battlefield(0, "Grizzly Bears")
	var b := put_battlefield(1, "Grizzly Bears")
	g.add_counters(glass, "time", 2)
	assert_eq(a.cur_power, 4)
	assert_eq(b.cur_power, 4)
	advance_to_step(Mtg.Step.UPKEEP)
	resolve_stack()
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.C, 3)
	assert_ok(g.activate_ability(1, glass, 0))
	resolve_stack()
	assert_eq(a.cur_power, 3)

func test_soul_barrier_triggers_only_for_an_opponents_creature_spell() -> void:
	put_battlefield(0, "Soul Barrier")
	advance_to_step(Mtg.Step.MAIN1)
	g.active_player = 1
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.G, 2)
	var bear := give_hand(1, "Grizzly Bears")
	assert_ok(g.cast_spell(1, bear))
	assert_eq(g.stack.size(), 2)
	resolve_stack()
	assert_eq(g.players[1].life, 18)

func test_despotic_scepter_checks_ownership_not_control() -> void:
	var scepter := put_battlefield(0, "Despotic Scepter")
	var bear := put_battlefield(0, "Grizzly Bears")
	g.change_control(bear, 1)
	advance_to_step(Mtg.Step.MAIN1)
	assert_ok(g.activate_ability(0, scepter, 0, [TargetRef.card(bear)]))
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
