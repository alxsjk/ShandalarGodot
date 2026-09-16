extends GameTest

func before_each() -> void:
	CardPacks.set_enabled("pack-5", true)
	super()
	advance_to_step(Mtg.Step.MAIN1)

func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-5", false)

func test_spirit_guide_is_stackless_hand_mana_and_not_battlefield_mana() -> void:
	var guide := give_hand(0, "Elvish Spirit Guide")
	var size := g.stack.size()
	assert_ok(g.tap_for_mana(0, guide))
	assert_eq(guide.zone, Mtg.Zone.EXILE)
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.G), 1)
	assert_eq(g.stack.size(), size)
	assert_refused(g.tap_for_mana(0, guide))
	var creature := put_battlefield(0, "Elvish Spirit Guide")
	assert_refused(g.tap_for_mana(0, creature))

func test_spirit_guide_planner_cannot_exile_the_spell_it_is_casting() -> void:
	var guide := give_hand(0, "Elvish Spirit Guide")
	put_battlefield(0, "Forest")
	put_battlefield(0, "Forest")
	assert_true(ManaPlanner.plan(g, 0, guide.data.cost, 0, g.mana_usage_keys(guide.data, guide)).is_empty())
	var bear := give_hand(0, "Grizzly Bears")
	var plan := ManaPlanner.plan(g, 0, bear.data.cost, 0, g.mana_usage_keys(bear.data, bear))
	assert_false(plan.is_empty())
	ManaPlanner.run_plan(g, 0, plan)
	assert_eq(guide.zone, Mtg.Zone.HAND, "prefer renewable lands over exiling the Guide")
	assert_ok(g.cast_spell(0, bear))

func test_lake_entry_sacrifices_a_swamp_before_arrival_and_fails_to_graveyard() -> void:
	var lake := give_hand(0, "Lake of the Dead")
	assert_ok(g.play_land(0, lake))
	assert_eq(lake.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[0].lands_played_this_turn, 1)
	var swamp := put_battlefield(0, "Swamp")
	var second := put_battlefield(0, "Lake of the Dead")
	assert_eq(swamp.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(second.zone, Mtg.Zone.BATTLEFIELD)

func test_trading_post_demands_an_untapped_mountain() -> void:
	var mountain := put_battlefield(0, "Mountain")
	g.tap_permanent(mountain)
	var failed := put_battlefield(0, "Balduvian Trading Post")
	assert_eq(failed.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(mountain.zone, Mtg.Zone.BATTLEFIELD)
	g.untap_permanent(mountain)
	var post := put_battlefield(0, "Balduvian Trading Post")
	assert_eq(mountain.zone, Mtg.Zone.GRAVEYARD)
	assert_ok(g.tap_for_mana(0, post))
	assert_eq(g.players[0].mana_pool.total(), 2)

func test_sheltered_valley_replaces_old_copies_before_own_entry() -> void:
	var first := put_battlefield(0, "Sheltered Valley")
	var second := put_battlefield(0, "Sheltered Valley")
	assert_eq(first.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(second.zone, Mtg.Zone.BATTLEFIELD)
	advance_to_next_turn()
	advance_to_next_turn()
	resolve_stack()
	assert_eq(g.players[0].life, 21)

func test_glaciers_finds_tapped_land_and_returns_at_cleanup_not_end_step() -> void:
	var glacier := put_battlefield(0, "Thawing Glaciers")
	assert_true(glacier.tapped)
	g.untap_permanent(glacier)
	add_mana(0, Mtg.ManaColor.C)
	var before := g.players[0].library.size()
	assert_ok(g.activate_ability(0, glacier, 0))
	resolve_stack()
	assert_eq(g.players[0].library.size(), before - 1)
	assert_eq(g.players[0].battlefield.size(), 2)
	assert_true(g.players[0].battlefield[1].tapped)
	advance_to_step(Mtg.Step.END)
	assert_eq(glacier.zone, Mtg.Zone.BATTLEFIELD)
	advance_to_next_turn()
	assert_eq(glacier.zone, Mtg.Zone.HAND)

func test_browse_moves_one_of_five_and_exiles_four() -> void:
	var browse := put_battlefield(0, "Browse")
	add_mana(0, Mtg.ManaColor.U, 4)
	var before := g.players[0].library.size()
	assert_ok(g.activate_ability(0, browse, 0))
	resolve_stack()
	assert_eq(g.players[0].library.size(), before - 5)
	assert_eq(g.players[0].hand.size(), 1)
	assert_eq(g.players[0].exile.size(), 4)

func test_adnate_only_sacrifices_black_or_artifact_creatures() -> void:
	var adnate := put_battlefield(0, "Soldevi Adnate")
	put_battlefield(0, "Grizzly Bears")
	assert_true(adnate.cur_mana_abilities[0].sacrifice_allows_self)
	var zombie := put_battlefield(0, "Scathe Zombies")
	# Explicitly choose the other black creature; self-sacrifice is also legal.
	g.players[0].battlefield.erase(zombie)
	g.players[0].battlefield.push_front(zombie)
	assert_ok(g.tap_for_mana(0, adnate))
	assert_eq(zombie.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.B), 3)

func test_gorilla_shaman_matches_x_and_pays_twice_x_plus_one() -> void:
	var shaman := put_battlefield(0, "Gorilla Shaman")
	var ring := put_battlefield(1, "Sol Ring")
	add_mana(0, Mtg.ManaColor.C, 3)
	assert_refused(g.activate_ability(0, shaman, 0, [TargetRef.card(ring)], 0))
	assert_ok(g.activate_ability(0, shaman, 0, [TargetRef.card(ring)], 1))
	assert_eq(g.players[0].mana_pool.total(), 0)
	resolve_stack()
	assert_eq(ring.zone, Mtg.Zone.GRAVEYARD)
