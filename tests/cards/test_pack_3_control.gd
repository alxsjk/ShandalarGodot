extends GameTest

func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()
	advance_to_step(Mtg.Step.MAIN1)
func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)

func cast_and_resolve(pid: int, name: String, targets: Array) -> void:
	var card := give_hand(pid, name)
	g.priority_player = pid
	for color in [Mtg.ManaColor.W, Mtg.ManaColor.U, Mtg.ManaColor.B, Mtg.ManaColor.R, Mtg.ManaColor.G]: add_mana(pid, color, 10)
	assert_ok(g.cast_spell(pid, card, targets))
	resolve_stack()

func test_ray_untaps_grants_haste_and_taps_after_control_returns() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	g.tap_permanent(bear)
	cast_and_resolve(0, "Ray of Command", [TargetRef.card(bear)])
	assert_eq(bear.controller_id, 0)
	assert_false(bear.tapped)
	assert_true(bear.has_keyword(Mtg.Keyword.HASTE))
	g.CONTROL_LAYERS.refresh(g, true)
	assert_eq(bear.controller_id, 1)
	assert_false(bear.tapped, "Tap waits for its delayed trigger")
	resolve_stack()
	assert_true(bear.tapped)

func test_borrowed_artifact_comes_back_to_reanimating_controller_not_owner() -> void:
	var ring := put_battlefield(1, "Sol Ring")
	g.change_control(ring, 0)
	var mage := put_battlefield(1, "Magus of the Unseen")
	mage.summoning_sick = false
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.U, 2)
	assert_ok(g.activate_ability(1, mage, 0, [TargetRef.card(ring)]))
	resolve_stack()
	assert_eq(ring.controller_id, 1)
	g.CONTROL_LAYERS.refresh(g, true)
	resolve_stack()
	assert_eq(ring.controller_id, 0)
	assert_true(ring.tapped)

func test_expired_underlying_leash_does_not_revive_after_borrow() -> void:
	var thief := put_battlefield(0, "Rubinia Soulsinger")
	g.tap_permanent(thief)
	var bear := put_battlefield(1, "Grizzly Bears")
	g.gain_control_leashed(bear, thief, true)
	g.gain_control_until_eot(bear, 1)
	g.untap_permanent(thief)
	g.CONTROL_LAYERS.refresh(g, true)
	assert_eq(bear.controller_id, 1)
	assert_eq(bear.controlled_via, -1)

func test_control_aura_ends_under_newer_control_and_never_revives() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	cast_and_resolve(0, "Control Magic", [TargetRef.card(bear)])
	var aura: CardInstance = g.find_instance(bear.attachments[0])
	g.gain_control_until_eot(bear, 1)
	g.return_to_hand(aura)
	assert_eq(bear.controller_id, 1)
	g.CONTROL_LAYERS.refresh(g, true)
	assert_eq(bear.controller_id, 1)

func test_newer_permanent_control_survives_expired_temporary_control() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	g.gain_control_until_eot(bear, 0)
	g.change_control(bear, 0)
	g.CONTROL_LAYERS.refresh(g, true)
	assert_eq(bear.controller_id, 0)

func test_temporary_control_does_not_follow_a_new_battlefield_entry() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	g.gain_control_until_eot(bear, 0)
	g.return_to_hand(bear)
	g.put_from_hand_into_play(bear, 0)
	g.CONTROL_LAYERS.refresh(g, true)
	assert_eq(bear.controller_id, 0)

func test_merieke_control_change_releases_without_destroying() -> void:
	var m := put_battlefield(0, "Merieke Ri Berit")
	var bear := put_battlefield(1, "Grizzly Bears")
	m.summoning_sick = false
	assert_ok(g.activate_ability(0, m, 0, [TargetRef.card(bear)]))
	resolve_stack()
	assert_eq(bear.controller_id, 0)
	g.change_control(m, 1)
	assert_eq(bear.controller_id, 1)
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_true(g.stack.is_empty())
	g.untap_permanent(m)
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)

func test_merieke_untap_destroys_without_regeneration_only_once() -> void:
	var m := put_battlefield(0, "Merieke Ri Berit")
	var bear := put_battlefield(1, "Grizzly Bears")
	m.summoning_sick = false
	assert_ok(g.activate_ability(0, m, 0, [TargetRef.card(bear)]))
	resolve_stack()
	bear.regeneration_shields = 1
	g.untap_permanent(m)
	assert_eq(bear.controller_id, 0, "Untapping doesn't end Merieke's control duration")
	assert_eq(g.stack.size(), 1)
	g.return_to_hand(m)
	assert_eq(g.stack.size(), 1, "The delayed trigger was already consumed")
	assert_eq(bear.controller_id, 1)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)

func test_denizen_control_duration_survives_source_changing_controllers() -> void:
	var demon := put_battlefield(0, "Infernal Denizen")
	var bear := put_battlefield(1, "Grizzly Bears")
	demon.summoning_sick = false
	assert_ok(g.activate_ability(0, demon, 0, [TargetRef.card(bear)]))
	resolve_stack()
	g.change_control(demon, 1)
	assert_eq(bear.controller_id, 0)
	g.return_to_hand(demon)
	assert_eq(bear.controller_id, 1)

func test_control_aura_moves_between_hosts_and_restores_each_base() -> void:
	var a := put_battlefield(1, "Grizzly Bears")
	var b := put_battlefield(1, "Hill Giant")
	cast_and_resolve(0, "Control Magic", [TargetRef.card(a)])
	var aura := g.find_instance(a.attachments[0])
	g.move_aura(aura, b)
	assert_eq(a.controller_id, 1)
	assert_eq(b.controller_id, 0)
	g.return_to_hand(aura)
	assert_eq(b.controller_id, 1)

func test_vampire_returns_all_qualifying_dead_cards_and_tracks_control_loss() -> void:
	var v := put_battlefield(0, "Krovikan Vampire")
	var bear := put_battlefield(1, "Grizzly Bears")
	g.deal_damage(v, TargetRef.card(bear), 1)
	g.destroy(bear, false)
	g.dispatch_event(Mtg.EventType.END_STEP_START, {"player": 0})
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(bear.controller_id, 0)
	g.change_control(v, 1)
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD, "Sacrifice uses the stack")
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)

func test_vampire_includes_creature_dying_in_response_to_end_trigger() -> void:
	var v := put_battlefield(0, "Krovikan Vampire")
	var a := put_battlefield(1, "Grizzly Bears")
	var b := put_battlefield(1, "Hill Giant")
	g.deal_damage(v, TargetRef.card(a), 1)
	g.deal_damage(v, TargetRef.card(b), 1)
	g.destroy(a, false)
	g.dispatch_event(Mtg.EventType.END_STEP_START, {"player": 0})
	g.destroy(b, false)
	resolve_stack()
	assert_eq(a.controller_id, 0)
	assert_eq(b.controller_id, 0)
	assert_eq(b.zone, Mtg.Zone.BATTLEFIELD)

func test_vampire_does_not_follow_card_after_it_leaves_graveyard() -> void:
	var v := put_battlefield(0, "Krovikan Vampire")
	var bear := put_battlefield(1, "Grizzly Bears")
	g.deal_damage(v, TargetRef.card(bear), 1)
	g.destroy(bear, false)
	g.reanimate(bear, 1)
	g.destroy(bear, false)
	g.dispatch_event(Mtg.EventType.END_STEP_START, {"player": 0})
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)

func test_returned_vampire_does_not_claim_previous_incarnations_damage() -> void:
	var v := put_battlefield(0, "Krovikan Vampire")
	var bear := put_battlefield(1, "Grizzly Bears")
	g.deal_damage(v, TargetRef.card(bear), 1)
	g.return_to_hand(v)
	g.put_from_hand_into_play(v, 0)
	g.destroy(bear, false)
	g.dispatch_event(Mtg.EventType.END_STEP_START, {"player": 0})
	assert_true(g.stack.is_empty())

func test_seraph_returns_card_even_when_seraph_leaves_before_return() -> void:
	var angel := put_battlefield(0, "Seraph")
	var bear := put_battlefield(1, "Grizzly Bears")
	g.deal_damage(angel, TargetRef.card(bear), 1)
	g.destroy(bear, false)
	resolve_stack()
	g.return_to_hand(angel)
	g.dispatch_event(Mtg.EventType.END_STEP_START, {"player": 0})
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(bear.controller_id, 0)
	g.put_from_hand_into_play(angel, 0)
	g.return_to_hand(angel)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD, "A new Seraph can't trigger the old sacrifice")

func test_seraph_sees_creatures_dying_simultaneously_with_it() -> void:
	var angel := put_battlefield(0, "Seraph")
	var bear := put_battlefield(1, "Grizzly Bears")
	g.begin_simultaneous()
	g.deal_damage(angel, TargetRef.card(bear), 4)
	g.deal_damage(bear, TargetRef.card(angel), 4)
	g.end_simultaneous()
	assert_eq(angel.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
	resolve_stack()
	g.dispatch_event(Mtg.EventType.END_STEP_START, {"player": 0})
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(bear.controller_id, 0)

func test_bone_shaman_blocks_regeneration_for_damage_already_dealt() -> void:
	var shaman := put_battlefield(0, "Bone Shaman")
	var bear := put_battlefield(1, "Grizzly Bears")
	g.deal_damage(shaman, TargetRef.card(bear), 1)
	add_mana(0, Mtg.ManaColor.B)
	assert_ok(g.activate_ability(0, shaman, 0))
	resolve_stack()
	assert_true(bear.regeneration_banned_this_turn)
	bear.regeneration_shields = 1
	g.destroy(bear)
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
