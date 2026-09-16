extends GameTest

func before_each() -> void:
	CardPacks.set_enabled("pack-5", true)
	super()
	advance_to_step(Mtg.Step.MAIN1)

func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-5", false)

func test_force_of_will_pays_life_and_a_different_blue_card_before_countering() -> void:
	var bolt := give_hand(0, "Lightning Bolt")
	add_mana(0, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(0, bolt, [TargetRef.player(1)]))
	g.pass_priority(0)
	var force := give_hand(1, "Force of Will")
	var pitch := give_hand(1, "Storm Crow")
	assert_ok(g.cast_spell(1, force, [TargetRef.card(bolt)], 0, 1))
	assert_eq(pitch.zone, Mtg.Zone.EXILE)
	assert_eq(g.players[1].life, 19)
	assert_eq(force.zone, Mtg.Zone.STACK)
	resolve_stack()
	assert_eq(g.players[1].life, 19)
	assert_eq(bolt.zone, Mtg.Zone.GRAVEYARD)

func test_force_cannot_exile_itself_and_a_refused_pitch_pays_nothing() -> void:
	var bolt := give_hand(0, "Lightning Bolt")
	add_mana(0, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(0, bolt, [TargetRef.player(1)]))
	g.pass_priority(0)
	var force := give_hand(1, "Force of Will")
	assert_refused(g.cast_spell(1, force, [TargetRef.card(bolt)], 0, 1))
	assert_eq(g.players[1].life, 20)
	assert_eq(force.zone, Mtg.Zone.HAND)
	assert_eq(g.stack.size(), 1)

func test_pitch_cost_is_not_a_zero_mana_value() -> void:
	var force := give_hand(0, "Force of Will")
	assert_eq(force.data.cost.mana_value(), 5)
	assert_eq(force.data.modes.size(), 2)

func test_library_exile_cost_is_paid_once_per_activation_before_resolution() -> void:
	var catapult := put_battlefield(0, "Whirling Catapult")
	var before := g.players[0].library.size()
	add_mana(0, Mtg.ManaColor.C, 4)
	assert_ok(g.activate_ability(0, catapult, 0))
	assert_eq(g.players[0].library.size(), before - 2)
	assert_ok(g.activate_ability(0, catapult, 0))
	assert_eq(g.players[0].library.size(), before - 4)
	resolve_stack()
	assert_eq(g.players[0].life, 18)
	assert_eq(g.players[1].life, 18)

func test_human_pitch_choice_holds_without_paying_and_replays_atomically() -> void:
	var bolt := give_hand(0, "Lightning Bolt")
	add_mana(0, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(0, bolt, [TargetRef.player(1)]))
	assert_ok(g.pass_priority(0))
	var force := give_hand(1, "Force of Will")
	var crow := give_hand(1, "Storm Crow")
	g.agents[1] = HumanAgent.new()
	g.interactive_choices = true
	assert_ok(g.cast_spell(1, force, [TargetRef.card(bolt)], 0, 1))
	assert_not_null(g.awaiting_choice)
	assert_eq(force.zone, Mtg.Zone.HAND)
	assert_eq(crow.zone, Mtg.Zone.HAND)
	assert_eq(g.players[1].life, 20)
	assert_ok(g.answer_choice("Storm Crow"))
	assert_null(g.awaiting_choice)
	assert_eq(force.zone, Mtg.Zone.STACK)
	assert_eq(crow.zone, Mtg.Zone.EXILE)
	assert_eq(g.players[1].life, 19)

func test_human_drone_holds_both_object_costs_before_either_is_paid() -> void:
	var drone := put_battlefield(0, "Viscerid Drone")
	var bear := put_battlefield(0, "Grizzly Bears")
	var swamp := put_battlefield(0, "Swamp")
	var angel := put_battlefield(1, "Serra Angel")
	g.agents[0] = HumanAgent.new()
	g.interactive_choices = true
	assert_ok(g.activate_ability(0, drone, 0, [TargetRef.card(angel)]))
	assert_not_null(g.awaiting_choice)
	assert_false(drone.tapped)
	assert_ok(g.answer_choice("Grizzly Bears"))
	assert_not_null(g.awaiting_choice)
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_ok(g.answer_choice("Swamp"))
	assert_null(g.awaiting_choice)
	assert_true(drone.tapped)
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(swamp.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(angel.zone, Mtg.Zone.BATTLEFIELD)
