extends GameTest

func before_each() -> void:
	CardPacks.set_enabled("pack-5", true)
	super()
	advance_to_step(Mtg.Step.MAIN1)

func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-5", false)

func pilot(seat := 0) -> AiPlayer:
	var ai := AiPlayer.new(seat, AiProfile.wizard())
	ai.profile.develops_late = false
	g.set_agent(seat, ai)
	return ai

func test_ai_can_pitch_force_of_will_when_tapped_out() -> void:
	g.players[1].life = 3
	var bolt := give_hand(0, "Lightning Bolt")
	add_mana(0, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(0, bolt, [TargetRef.player(1)]))
	assert_ok(g.pass_priority(0))
	var force := give_hand(1, "Force of Will")
	var crow := give_hand(1, "Storm Crow")
	var ai := pilot(1)
	ai.profile.forecasts_tactics = false
	assert_eq(ai._respond_action(g), "")
	ai.profile.forecasts_tactics = true
	assert_ne(ai._respond_action(g), "")
	assert_eq(force.zone, Mtg.Zone.STACK)
	assert_eq(crow.zone, Mtg.Zone.EXILE)
	resolve_stack()
	assert_eq(g.players[1].life, 2)

func test_ai_uses_browse_without_looking_at_top_five_before_activation() -> void:
	put_battlefield(0, "Browse")
	add_mana(0, Mtg.ManaColor.U, 4)
	var ai := pilot()
	var before := g.rng.state
	assert_eq(ai._try_activate(g), "activated Browse")
	assert_eq(g.rng.state, before)
	resolve_stack()
	assert_eq(g.players[0].hand.size(), 1)
	assert_eq(g.players[0].exile.size(), 4)

func test_ai_sizes_gorilla_shaman_to_enemy_artifact() -> void:
	put_battlefield(0, "Gorilla Shaman")
	var target := put_battlefield(1, "Sol Ring")
	add_mana(0, Mtg.ManaColor.C, 3)
	var ai := pilot()
	var shaman := g.players[0].battlefield[0]
	assert_true(ai._ability_available(g, shaman, 0, true))
	var option: Dictionary = preload("res://engine/ai/alliances_tactics.gd").option(g, ai, shaman, 0, "MAIN")
	assert_false(option.is_empty())
	assert_false(ai._ability_option(g, shaman, 0, AiPlayer.Moment.MAIN).is_empty())
	assert_eq(ai._try_activate(g), "activated Gorilla Shaman")
	if g.stack.is_empty(): return
	assert_eq(g.stack.back().x_value, 1)
	assert_eq(g.stack.back().targets[0].instance_id, target.id)
	resolve_stack()
	assert_eq(target.zone, Mtg.Zone.GRAVEYARD)

func test_ai_will_not_exile_its_last_library_card_for_small_lifegain() -> void:
	put_battlefield(0, "Royal Herbalist")
	add_mana(0, Mtg.ManaColor.C, 2)
	while g.players[0].library.size() > 1: g.exile_top_of_library(0, false)
	assert_eq(pilot()._try_activate(g, AiPlayer.Moment.SINK), "")

func test_ai_pitches_scars_to_prevent_lethal_bolt_without_using_rng() -> void:
	g.players[1].life = 3
	var bolt := give_hand(0, "Lightning Bolt")
	add_mana(0, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(0, bolt, [TargetRef.player(1)]))
	assert_ok(g.pass_priority(0))
	var scars := give_hand(1, "Scars of the Veteran")
	var pitch := give_hand(1, "Errand of Duty")
	var ai := pilot(1)
	var rng := g.rng.state
	assert_eq(preload("res://engine/ai/alliances_tactics.gd").special_spell(g, ai, true), "cast Scars of the Veteran")
	assert_eq(g.rng.state, rng)
	assert_eq(scars.zone, Mtg.Zone.STACK)
	assert_eq(pitch.zone, Mtg.Zone.EXILE)
	resolve_stack()
	assert_eq(g.players[1].life, 3)

func test_ai_pitches_bounty_to_save_a_valuable_creature() -> void:
	var angel := put_battlefield(1, "Serra Angel")
	g.deal_damage(give_hand(0, "Lightning Bolt"), TargetRef.card(angel), 2)
	var bolt := give_hand(0, "Lightning Bolt")
	add_mana(0, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(0, bolt, [TargetRef.card(angel)]))
	assert_ok(g.pass_priority(0))
	var bounty := give_hand(1, "Bounty of the Hunt")
	var pitch := give_hand(1, "Giant Growth")
	assert_eq(preload("res://engine/ai/alliances_tactics.gd").special_spell(g, pilot(1), true), "cast Bounty of the Hunt")
	assert_eq(bounty.zone, Mtg.Zone.STACK)
	assert_eq(pitch.zone, Mtg.Zone.EXILE)
	resolve_stack()
	assert_eq(angel.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(angel.cur_toughness, 7)

func test_ai_library_policy_cannot_see_hidden_hand_or_top_order() -> void:
	var browse := put_battlefield(0, "Browse")
	var ai := pilot()
	var tactics := preload("res://engine/ai/alliances_tactics.gd")
	var first: Dictionary = tactics.option(g, ai, browse, 0, "MAIN")
	give_hand(1, "Force of Will")
	give_hand(1, "Wrath of God")
	g.players[0].library.reverse()
	g.players[1].library.reverse()
	var state := g.rng.state
	var second: Dictionary = tactics.option(g, ai, browse, 0, "MAIN")
	assert_eq(first, second)
	assert_eq(g.rng.state, state)
	assert_null(g.undo_log)

func test_ai_pitch_scars_in_classic_prevention_window() -> void:
	g.rules.set_edition("fifth")
	g.players[0].life = 2
	var bolt := give_hand(1, "Lightning Bolt")
	var packet := plant_damage_packet(bolt, TargetRef.player(0), 3)
	g.awaiting_damage_prevention = true
	var scars := give_hand(0, "Scars of the Veteran")
	give_hand(0, "Errand of Duty")
	assert_ne(pilot()._spend_on_packet(g, packet, AiPlayer.LETHAL_WORTH), "")
	assert_eq(scars.zone, Mtg.Zone.STACK)

func test_fighter_does_not_loop_killing_a_guaranteed_return_outside_combat() -> void:
	var gorilla := put_battlefield(0, "Gargantuan Gorilla")
	put_battlefield(1, "Ivory Gargoyle")
	var ai := pilot()
	assert_eq(preload("res://engine/ai/alliances_tactics.gd").option(g, ai, gorilla, 0, "MAIN"), {})
	assert_false(gorilla.tapped)

func test_fighter_values_an_ordinary_enemy_without_executing_the_fight() -> void:
	var gorilla := put_battlefield(0, "Gargantuan Gorilla")
	var angel := put_battlefield(1, "Serra Angel")
	advance_to_step(Mtg.Step.MAIN2)
	var choice: Dictionary = preload("res://engine/ai/alliances_tactics.gd").option(g, pilot(), gorilla, 0, "MAIN")
	assert_false(choice.is_empty())
	assert_eq(choice.targets[0].instance_id, angel.id)
	assert_false(gorilla.tapped)
	assert_eq(angel.damage, 0)

func test_ai_exile_chooses_enemy_attacker_and_ignores_unrelated_homelands_roles() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [bear.id]))
	assert_ok(g.pass_priority(0))
	var exile := give_hand(1, "Exile")
	add_mana(1, Mtg.ManaColor.W, 3)
	var ai := pilot(1)
	assert_null(preload("res://engine/ai/homelands_tactics.gd").spell_choice(g, ai, exile))
	assert_eq(preload("res://engine/ai/alliances_tactics.gd").special_spell(g, ai, true), "cast Exile")
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.EXILE)
	assert_eq(g.players[1].life, 22)
