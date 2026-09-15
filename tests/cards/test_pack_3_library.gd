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

func test_necro_skips_draw_step_but_not_independent_draws() -> void:
	put_battlefield(0, "Necropotence")
	assert_true(g._draw_step_skipped(0))
	assert_false(g._draw_step_skipped(1))
	g.draw_cards(0, 1)
	assert_eq(g.players[0].hand.size(), 1)

func test_necro_pays_life_and_exiles_uninspectable_card_until_own_end() -> void:
	var necro := put_battlefield(0, "Necropotence")
	assert_ok(g.activate_ability(0, necro, 0))
	assert_eq(g.players[0].life, 19)
	resolve_stack()
	var i: CardInstance = g.players[0].exile.back()
	assert_true(i.face_down)
	var view := AiObservation.capture(g, 0)
	assert_false(view.players[0].exile[0].has("name"))
	g.dispatch_event(Mtg.EventType.END_STEP_START, {"player": 1})
	resolve_stack()
	assert_eq(i.zone, Mtg.Zone.EXILE)
	g.return_to_hand(necro)
	g.dispatch_event(Mtg.EventType.END_STEP_START, {"player": 0})
	resolve_stack()
	assert_eq(i.zone, Mtg.Zone.HAND)
	assert_false(i.face_down)

func test_necro_delayed_hand_return_does_not_follow_a_new_exile_entry() -> void:
	var necro := put_battlefield(0, "Necropotence")
	assert_ok(g.activate_ability(0, necro, 0))
	resolve_stack()
	var i: CardInstance = g.players[0].exile.back()
	var first := i.exile_entry
	g.return_from_exile_to_graveyard(i)
	g.exile_from_graveyard(i)
	assert_gt(i.exile_entry, first)
	g.dispatch_event(Mtg.EventType.END_STEP_START, {"player": 0})
	resolve_stack()
	assert_eq(i.zone, Mtg.Zone.EXILE)

func test_necro_discard_is_responseable_and_bound_to_graveyard_entry() -> void:
	put_battlefield(0, "Necropotence")
	var card := give_hand(0, "Island")
	g.discard_cards(0, [card])
	assert_eq(card.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.stack.size(), 1)
	g.return_from_graveyard_to_hand(card)
	g.put_from_hand_on_top_of_library(card)
	g.mill(0, 1) # a fresh graveyard entry, without another discard trigger
	resolve_stack()
	assert_eq(card.zone, Mtg.Zone.GRAVEYARD)

func test_enduring_renewal_reveals_hand_mills_creatures_and_draws_noncreatures() -> void:
	var renewal := put_battlefield(0, "Enduring Renewal")
	var bear := give_hand(0, "Grizzly Bears")
	g.put_from_hand_on_top_of_library(bear)
	g.draw_cards(0, 1)
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[0].drawn_this_turn.size(), 0)
	var island := give_hand(0, "Island")
	g.put_from_hand_on_top_of_library(island)
	g.draw_cards(0, 1)
	assert_eq(island.zone, Mtg.Zone.HAND)
	assert_eq(AiObservation.capture(g, 1).players[0].known_hand.size(), 1)
	g.return_to_hand(renewal)
	assert_false(g.players[0].hand_revealed)
	assert_eq(AiObservation.capture(g, 1).players[0].known_hand.size(), 0)

func test_enduring_returns_owned_creatures_even_when_opponent_controlled_them() -> void:
	put_battlefield(0, "Enduring Renewal")
	var bear := put_battlefield(0, "Grizzly Bears")
	g.change_control(bear, 1)
	g.sacrifice_permanent(bear)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.HAND)
	assert_has(g.players[0].hand, bear)

func test_weirding_payment_replaces_draw_and_reveals_both_hands() -> void:
	put_battlefield(0, "Zur's Weirding")
	g.agents[1] = Always.new()
	var bear := give_hand(0, "Grizzly Bears")
	g.put_from_hand_on_top_of_library(bear)
	g.draw_cards(0, 1)
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[1].life, 18)
	assert_true(g.players[0].hand_revealed)
	assert_true(g.players[1].hand_revealed)

func test_jesters_cap_exiles_exactly_three_cards_and_sacrifices_as_cost() -> void:
	var cap := put_battlefield(0, "Jester's Cap")
	var before := g.players[1].library.size()
	add_mana(0, Mtg.ManaColor.C, 2)
	assert_ok(g.activate_ability(0, cap, 0, [TargetRef.player(1)]))
	assert_eq(cap.zone, Mtg.Zone.GRAVEYARD)
	resolve_stack()
	assert_eq(g.players[1].library.size(), before - 3)
	assert_eq(g.players[1].exile.size(), 3)
	for i in g.players[1].exile: assert_false(i.face_down)

func test_jesters_mask_keeps_hand_count_without_draw_or_discard() -> void:
	var mask := put_battlefield(0, "Jester's Mask")
	assert_true(mask.tapped)
	g.untap_permanent(mask)
	give_hand(1, "Island")
	give_hand(1, "Grizzly Bears")
	var library := g.players[1].library.size()
	add_mana(0, Mtg.ManaColor.C)
	assert_refused(g.activate_ability(0, mask, 0, [TargetRef.player(0)]))
	assert_ok(g.activate_ability(0, mask, 0, [TargetRef.player(1)]))
	resolve_stack()
	assert_eq(g.players[1].library.size(), library)
	assert_eq(g.players[1].hand.size(), 2)
	assert_eq(g.players[1].drawn_this_turn.size(), 0)
	assert_true(g.players[1].graveyard.is_empty())

func test_icy_prison_has_responseable_return_and_uses_owner_not_controller() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	g.change_control(bear, 0)
	var prison := put_battlefield(0, "Icy Prison")
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.EXILE)
	g.sacrifice_permanent(prison)
	assert_eq(bear.zone, Mtg.Zone.EXILE)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(bear.controller_id, 1)

func test_icy_prison_leaving_before_etb_does_not_return_future_prisoner() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	var prison := put_battlefield(0, "Icy Prison")
	g.sacrifice_permanent(prison)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.EXILE)

func test_ai_necro_budgets_pending_cards_without_reading_them() -> void:
	var necro := put_battlefield(0, "Necropotence")
	var ai := AiPlayer.new(0, AiProfile.wizard())
	ai.profile.develops_late = false
	g.agents[0] = ai
	for _i in 6:
		assert_eq(ai._try_activate(g), "activated Necropotence")
		resolve_stack()
	assert_eq(ai._try_activate(g), "")
	assert_eq(g.players[0].life, 14)
	assert_eq(g.delayed_triggers.size(), 6)

func test_ashen_ghoul_activates_only_from_graveyard_during_own_upkeep() -> void:
	var ghoul := put_battlefield(0, "Ashen Ghoul")
	add_mana(0, Mtg.ManaColor.B, 3)
	assert_refused(g.activate_ability(0, ghoul, 0), "zone")
	g.sacrifice_permanent(ghoul)
	for _i in 3: g.sacrifice_permanent(put_battlefield(0, "Grizzly Bears"))
	assert_refused(g.activate_ability(0, ghoul, 0), "upkeep")
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.UPKEEP)
	assert_ok(g.activate_ability(0, ghoul, 0))
	# Removing the cards above it does not undo a legal activation.
	var top: CardInstance = g.players[0].graveyard.back()
	g.exile_from_graveyard(top)
	resolve_stack()
	assert_eq(ghoul.zone, Mtg.Zone.BATTLEFIELD)
	assert_true(ghoul.has_keyword(Mtg.Keyword.HASTE))

func test_whiteout_recursion_pays_snow_land_as_cost_and_uses_grave_incarnation() -> void:
	var whiteout := give_hand(0, "Whiteout")
	g.discard_cards(0, [whiteout])
	var snow := put_battlefield(0, "Snow-Covered Forest")
	assert_ok(g.activate_ability(0, whiteout, 0))
	assert_eq(snow.zone, Mtg.Zone.GRAVEYARD)
	g.return_from_graveyard_to_hand(whiteout)
	g.discard_cards(0, [whiteout])
	resolve_stack()
	assert_eq(whiteout.zone, Mtg.Zone.GRAVEYARD)

func test_whiteout_loses_flying_until_cleanup_and_not_later_grants() -> void:
	var angel := put_battlefield(1, "Serra Angel")
	var whiteout := give_hand(0, "Whiteout")
	add_mana(0, Mtg.ManaColor.G, 2)
	assert_ok(g.cast_spell(0, whiteout))
	resolve_stack()
	assert_false(angel.has_keyword(Mtg.Keyword.FLYING))
	g.continuous.add_until_eot_keywords(angel.id, [Mtg.Keyword.FLYING])
	g.recalculate()
	assert_true(angel.has_keyword(Mtg.Keyword.FLYING))

func test_ai_can_activate_ashen_ghoul_in_its_graveyard() -> void:
	var ghoul := put_battlefield(0, "Ashen Ghoul")
	g.sacrifice_permanent(ghoul)
	for _i in 3: g.sacrifice_permanent(put_battlefield(0, "Grizzly Bears"))
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.UPKEEP)
	add_mana(0, Mtg.ManaColor.B)
	var ai := AiPlayer.new(0, AiProfile.wizard())
	g.agents[0] = ai
	assert_eq(ai._try_activate(g, AiPlayer.Moment.UPKEEP), "activated Ashen Ghoul")
	resolve_stack()
	assert_eq(ghoul.zone, Mtg.Zone.BATTLEFIELD)

func test_bottle_allows_normal_cast_from_exile_even_after_bottle_leaves() -> void:
	var bottle := put_battlefield(0, "Elkin Bottle")
	var bear := give_hand(0, "Grizzly Bears")
	g.put_from_hand_on_top_of_library(bear)
	add_mana(0, Mtg.ManaColor.C, 3)
	assert_ok(g.activate_ability(0, bottle, 0))
	resolve_stack()
	assert_true(g.can_play_from_exile(0, bear))
	g.return_to_hand(bottle)
	add_mana(0, Mtg.ManaColor.G, 2)
	assert_ok(g.cast_spell(0, bear))
	assert_false(g.players[0].exile.has(bear))
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)

func test_bottle_land_still_uses_normal_land_drop_limit() -> void:
	var bottle := put_battlefield(0, "Elkin Bottle")
	add_mana(0, Mtg.ManaColor.C, 3)
	assert_ok(g.activate_ability(0, bottle, 0))
	resolve_stack()
	var land: CardInstance = g.players[0].exile.back()
	assert_ok(g.play_land(0, land))
	var second := give_hand(0, "Island")
	assert_refused(g.play_land(0, second), "already")
	assert_false(g.players[0].exile.has(land))

func test_bottle_permission_expires_before_next_own_upkeep_triggers() -> void:
	var bottle := put_battlefield(0, "Elkin Bottle")
	add_mana(0, Mtg.ManaColor.C, 3)
	assert_ok(g.activate_ability(0, bottle, 0))
	resolve_stack()
	var land: CardInstance = g.players[0].exile.back()
	g._enter_step(Mtg.STEP_ORDER.find(Mtg.Step.UPKEEP))
	assert_false(g.can_play_from_exile(0, land))
	assert_eq(land.zone, Mtg.Zone.EXILE)

func test_ai_plays_a_land_with_bottle_permission() -> void:
	var land: CardInstance = g.players[0].library.back()
	g.exile_library_card(land)
	g.grant_exile_play(land, 0, true)
	var ai := AiPlayer.new(0, AiProfile.wizard())
	g.agents[0] = ai
	assert_true(ai._try_play_land(g))
	assert_eq(land.zone, Mtg.Zone.BATTLEFIELD)

func test_new_exile_incarnation_has_no_stale_play_permission() -> void:
	var land: CardInstance = g.players[0].library.back()
	g.exile_library_card(land)
	g.grant_exile_play(land, 0, true)
	g.return_from_exile_to_graveyard(land)
	g.exile_from_graveyard(land)
	assert_false(g.can_play_from_exile(0, land))
