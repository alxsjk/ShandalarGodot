extends GameTest

func before_each() -> void:
	CardPacks.set_enabled("pack-4", true)
	super()
	advance_to_step(Mtg.Step.MAIN1)

func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-4", false)

func test_oyster_lock_ends_immediately_on_untap_and_does_not_restart_on_retap() -> void:
	var oyster := put_battlefield(0, "Giant Oyster")
	var bear := put_battlefield(1, "Grizzly Bears")
	g.tap_permanent(bear)
	assert_ok(g.activate_ability(0, oyster, 0, [TargetRef.card(bear)]))
	resolve_stack()
	assert_true(bear.cur_skips_untap)
	g.dispatch_event(Mtg.EventType.DRAW_STEP, {"player": 0})
	resolve_stack()
	assert_eq(int(bear.counters.get("-1/-1", 0)), 1)
	g.untap_permanent(oyster)
	assert_false(bear.cur_skips_untap)
	g.tap_permanent(oyster)
	assert_false(bear.cur_skips_untap)
	resolve_stack()
	assert_eq(int(bear.counters.get("-1/-1", 0)), 0)
	g.dispatch_event(Mtg.EventType.DRAW_STEP, {"player": 0})
	resolve_stack()
	assert_eq(int(bear.counters.get("-1/-1", 0)), 0)

func test_oyster_release_removes_all_minus_counters_but_not_from_a_blinked_target() -> void:
	var oyster := put_battlefield(0, "Giant Oyster")
	var wall := put_battlefield(1, "Wall of Stone")
	g.tap_permanent(wall)
	assert_ok(g.activate_ability(0, oyster, 0, [TargetRef.card(wall)]))
	resolve_stack()
	g.add_counters(wall, "-1/-1", 3)
	g.return_to_hand(oyster)
	resolve_stack()
	assert_eq(int(wall.counters.get("-1/-1", 0)), 0)
	g.put_from_hand_into_play(oyster, 0)
	oyster.summoning_sick = false
	assert_ok(g.activate_ability(0, oyster, 0, [TargetRef.card(wall)]))
	resolve_stack()
	g.return_to_hand(wall)
	g.put_from_hand_into_play(wall, 1)
	g.add_counters(wall, "-1/-1", 2)
	g.untap_permanent(oyster)
	resolve_stack()
	assert_eq(int(wall.counters.get("-1/-1", 0)), 2)

func test_hazduhr_splits_damage_and_preserves_the_actual_source() -> void:
	var abbot := put_battlefield(0, "Hazduhr the Abbot")
	var white := put_battlefield(0, "Serra Paladin")
	var red := put_battlefield(1, "Anaba Shaman")
	add_mana(0, Mtg.ManaColor.C, 2)
	assert_ok(g.activate_ability(0, abbot, 0, [TargetRef.card(white)], 2))
	resolve_stack()
	assert_eq(g.deal_damage(red, TargetRef.card(white), 3), 3)
	assert_eq(white.damage, 1)
	assert_eq(abbot.damage, 2)
	assert_true(abbot.damage_origins_this_turn.has("%d:%d" % [red.id, red.layer_timestamp]))
	assert_false(abbot.damage_origins_this_turn.has("%d:%d" % [abbot.id, abbot.layer_timestamp]))

func test_daughter_destination_blink_invalidates_the_redirect() -> void:
	var daughter := put_battlefield(0, "Daughter of Autumn")
	var white := put_battlefield(0, "Serra Paladin")
	var red := put_battlefield(1, "Anaba Shaman")
	add_mana(0, Mtg.ManaColor.W)
	assert_ok(g.activate_ability(0, daughter, 0, [TargetRef.card(white)]))
	resolve_stack()
	g.return_to_hand(daughter)
	g.put_from_hand_into_play(daughter, 0)
	g.deal_damage(red, TargetRef.card(white), 1)
	assert_eq(white.damage, 1)
	assert_eq(daughter.damage, 0)

func test_daughter_can_save_an_opponents_white_creature_but_hazduhr_cannot() -> void:
	var daughter := put_battlefield(0, "Daughter of Autumn")
	var abbot := put_battlefield(0, "Hazduhr the Abbot")
	var white := put_battlefield(1, "Serra Paladin")
	var red := put_battlefield(1, "Anaba Shaman")
	add_mana(0, Mtg.ManaColor.W, 3)
	assert_refused(g.activate_ability(0, abbot, 0, [TargetRef.card(white)], 1))
	assert_ok(g.activate_ability(0, daughter, 0, [TargetRef.card(white)]))
	resolve_stack()
	g.deal_damage(red, TargetRef.card(white), 1)
	assert_eq(white.damage, 0)
	assert_eq(daughter.damage, 1)

func test_metered_redirect_undo_cycle_and_cleanup() -> void:
	var abbot := put_battlefield(0, "Hazduhr the Abbot")
	var white := put_battlefield(0, "Serra Paladin")
	var red := put_battlefield(1, "Anaba Shaman")
	g.book_creature_redirect(white, abbot, 5)
	g.book_creature_redirect(abbot, white, 5)
	var mark := g.make_mark()
	assert_eq(g.deal_damage(red, TargetRef.card(white), 1), 1)
	assert_eq(white.damage, 1, "each replacement applies only once; no infinite redirect loop")
	assert_eq(abbot.damage, 0)
	g.unmake_to(mark)
	assert_eq(white.damage, 0)
	assert_eq(int(white.creature_damage_redirects[0].remaining), 5)
	assert_eq(int(abbot.creature_damage_redirects[0].remaining), 5)
	g.end_search()
	advance_to_next_turn()
	assert_true(white.creature_damage_redirects.is_empty())

func test_classic_redirection_opens_a_second_damage_window() -> void:
	var abbot := put_battlefield(0, "Hazduhr the Abbot")
	var white := put_battlefield(0, "Serra Paladin")
	var red := put_battlefield(1, "Anaba Shaman")
	g.rules.damage_prevention_window = true
	g.set_agent(1, AiPlayer.new(1, AiProfile.wizard()))
	g.book_creature_redirect(white, abbot, 2)
	g.deal_damage(red, TargetRef.card(white), 3)
	g._open_priority()
	assert_true(g.awaiting_damage_prevention)
	assert_ok(g.pass_priority(g.priority_player))
	assert_ok(g.pass_priority(g.priority_player))
	assert_eq(white.damage, 1)
	assert_eq(abbot.damage, 0)
	assert_eq(g.damage_pending.size(), 1)
	var guard := 0
	while g.awaiting_damage_prevention and guard < 12:
		guard += 1
		assert_ok(g.pass_priority(g.priority_player))
	assert_lt(guard, 12)
	assert_eq(abbot.damage, 2)

func test_your_next_untap_is_player_bound_after_a_control_change() -> void:
	var reveka := put_battlefield(0, "Reveka, Wizard Savant")
	assert_ok(g.activate_ability(0, reveka, 0, [TargetRef.player(1)]))
	resolve_stack()
	assert_eq(reveka.skip_untap_for, [0])
	g.change_control(reveka, 1)
	advance_to_next_turn()
	assert_false(reveka.tapped, "not player zero's untap: player one may untap the stolen creature")
	assert_eq(reveka.skip_untap_for, [0])
	advance_to_next_turn()
	assert_true(reveka.skip_untap_for.is_empty(), "the named step consumes it even on the other side")

func test_existing_packet_undo_restores_redirect_budget_and_applied_history() -> void:
	var abbot := put_battlefield(0, "Hazduhr the Abbot")
	var white := put_battlefield(0, "Serra Paladin")
	var red := put_battlefield(1, "Anaba Shaman")
	g.book_creature_redirect(white, abbot, 2)
	var packet := g._plan_damage(red, TargetRef.card(white), 3, false)
	var mark := g.make_mark()
	g._land_damage(packet)
	g.unmake_to(mark)
	g.end_search()
	assert_eq(packet.redirected, 0)
	assert_true(packet.applied_creature_redirects.is_empty())
	assert_eq(packet.remaining(), 3)
	assert_eq(int(white.creature_damage_redirects[0].remaining), 2)

func test_classic_redirect_cannot_damage_a_new_recipient_incarnation() -> void:
	var abbot := put_battlefield(0, "Hazduhr the Abbot")
	var white := put_battlefield(0, "Serra Paladin")
	var red := put_battlefield(1, "Anaba Shaman")
	g.rules.damage_prevention_window = true
	g.set_agent(1, AiPlayer.new(1, AiProfile.wizard()))
	g.book_creature_redirect(white, abbot, 2)
	g.deal_damage(red, TargetRef.card(white), 3)
	g._open_priority()
	assert_ok(g.pass_priority(g.priority_player))
	assert_ok(g.pass_priority(g.priority_player))
	assert_eq(g.damage_pending.size(), 1)
	g.return_to_hand(abbot)
	g.put_from_hand_into_play(abbot, 0)
	var guard := 0
	while g.awaiting_damage_prevention and guard < 12:
		guard += 1
		assert_ok(g.pass_priority(g.priority_player))
	assert_lt(guard, 12)
	assert_eq(abbot.damage, 0, "the old redirect cannot hit a returned Abbot")
