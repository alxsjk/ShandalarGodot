extends GameTest

func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()

func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)

func test_chub_toad_triggers_once_when_blocked_by_two_creatures() -> void:
	var toad := put_battlefield(0, "Chub Toad")
	var a := put_battlefield(1, "Grizzly Bears")
	var b := put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [toad.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {a.id: toad.id, b.id: toad.id}))
	assert_eq(g.stack.size(), 1)
	resolve_stack()
	assert_eq(toad.cur_power, 3)
	assert_eq(toad.cur_toughness, 3)

func test_aurochs_counts_other_attacking_aurochs_not_bystanders() -> void:
	var a := put_battlefield(0, "Aurochs")
	var b := put_battlefield(0, "Aurochs")
	put_battlefield(0, "Aurochs")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [a.id, b.id]))
	resolve_stack()
	assert_eq(a.cur_power, 3)
	assert_eq(b.cur_power, 3)

func test_lhurgoyf_tracks_both_graveyards_live() -> void:
	var a := put_battlefield(0, "Grizzly Bears")
	var b := put_battlefield(1, "Grizzly Bears")
	g.sacrifice_permanent(a)
	g.sacrifice_permanent(b)
	var goyf := put_battlefield(0, "Lhurgoyf")
	assert_eq(Vector2i(goyf.cur_power, goyf.cur_toughness), Vector2i(2, 3))
	g.exile_from_graveyard(a)
	g.recalculate()
	assert_eq(Vector2i(goyf.cur_power, goyf.cur_toughness), Vector2i(1, 2))

func test_lost_order_remembers_chosen_opponent_after_control_changes() -> void:
	put_battlefield(1, "Grizzly Bears")
	var knight := put_battlefield(0, "Lost Order of Jarkeld")
	assert_eq(knight.cur_power, 2)
	g.change_control(knight, 1)
	assert_eq(knight.cur_power, 3)

func test_mistfolk_can_only_counter_a_spell_that_targets_it() -> void:
	var folk := put_battlefield(0, "Mistfolk")
	var other := put_battlefield(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	var bolt := give_hand(1, "Lightning Bolt")
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(1, bolt, [TargetRef.card(other)]))
	g.priority_player = 0
	add_mana(0, Mtg.ManaColor.U)
	assert_refused(g.activate_ability(0, folk, 0, [TargetRef.card(bolt)]))
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.U), 1)

func test_sacrificed_tinder_wall_still_hits_its_blocked_creature() -> void:
	var attacker := put_battlefield(0, "Grizzly Bears")
	var wall := put_battlefield(1, "Tinder Wall")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {wall.id: attacker.id}))
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.R)
	assert_ok(g.activate_ability(1, wall, 0, [TargetRef.card(attacker)]))
	assert_eq(wall.zone, Mtg.Zone.GRAVEYARD)
	resolve_stack()
	assert_eq(attacker.zone, Mtg.Zone.GRAVEYARD)

func test_blinking_spirit_old_activation_does_not_bounce_returned_card() -> void:
	var spirit := put_battlefield(0, "Blinking Spirit")
	advance_to_step(Mtg.Step.MAIN1)
	assert_ok(g.activate_ability(0, spirit, 0))
	g.return_to_hand(spirit)
	g._put_on_battlefield(spirit, 0)
	resolve_stack()
	assert_eq(spirit.zone, Mtg.Zone.BATTLEFIELD)

func test_elvish_healer_prevents_two_for_green_creature_and_one_for_player() -> void:
	var healer := put_battlefield(0, "Elvish Healer")
	var bear := put_battlefield(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	assert_ok(g.activate_ability(0, healer, 0, [TargetRef.card(bear)]))
	resolve_stack()
	assert_eq(bear.prevention, 2)
	g.untap_permanent(healer)
	assert_ok(g.activate_ability(0, healer, 0, [TargetRef.player(0)]))
	resolve_stack()
	assert_eq(g.players[0].damage_prevention, 1)

func test_karplusan_yeti_uses_last_known_power_after_it_dies() -> void:
	var yeti := put_battlefield(0, "Karplusan Yeti")
	var bear := put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.MAIN1)
	assert_ok(g.activate_ability(0, yeti, 0, [TargetRef.card(bear)]))
	g.sacrifice_permanent(yeti)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)

func test_stone_spirit_cannot_be_blocked_by_flyers_but_can_by_ground() -> void:
	var spirit := put_battlefield(0, "Stone Spirit")
	var flyer := put_battlefield(1, "Air Elemental")
	var bear := put_battlefield(1, "Grizzly Bears")
	assert_ne(CombatState.block_illegality(g, flyer, spirit, 1), "")
	assert_eq(CombatState.block_illegality(g, bear, spirit, 1), "")

func test_soldevi_machinist_mana_only_pays_artifact_abilities() -> void:
	var worker := put_battlefield(0, "Soldevi Machinist")
	var icy := put_battlefield(0, "Icy Manipulator")
	var bear := put_battlefield(1, "Grizzly Bears")
	var enchanter := put_battlefield(0, "Zuran Enchanter")
	advance_to_step(Mtg.Step.MAIN1)
	assert_ok(g.tap_for_mana(0, worker))
	assert_false(g.can_afford(0, CardRegistry.get_card("Sol Ring")))
	assert_ok(g.activate_ability(0, icy, 0, [TargetRef.card(bear)]))
	resolve_stack()
	assert_true(bear.tapped)
	add_mana(0, Mtg.ManaColor.B)
	assert_refused(g.activate_ability(0, enchanter, 0, [TargetRef.player(1)]), "not enough mana")

func test_ai_plans_machinist_mana_for_an_artifact_draw_ability() -> void:
	put_battlefield(0, "Soldevi Machinist")
	put_battlefield(0, "Sol Ring")
	put_battlefield(0, "Jayemdae Tome")
	advance_to_step(Mtg.Step.MAIN1)
	var ai := AiPlayer.new(0, AiProfile.wizard())
	ai.profile.develops_late = false
	g.agents[0] = ai
	assert_eq(ai._try_activate(g, AiPlayer.Moment.SINK), "activated Jayemdae Tome")
	resolve_stack()
	assert_eq(g.players[0].hand.size(), 1)

func test_goblin_mutant_stays_home_against_a_pumped_defender() -> void:
	# The Orgg clause on an Ice Age body: a question ABOUT a power, asked
	# after every P/T layer (CR 613.8, StaticAbility.reading_pt). The
	# anthem pass ran a pass ahead of the floating pumps, so the Mutant
	# attacked into a Giant-Growthed 2/2 it could not see.
	var mutant := put_battlefield(0, "Goblin Mutant")
	var bear := put_battlefield(1, "Grizzly Bears")
	g.continuous.add_until_eot_pump(bear.id, 1, 1)   # an untapped 3/3
	g.recalculate()
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_refused(g.declare_attackers(0, [mutant.id]), "can't attack")

func test_goblin_mutant_attacks_past_a_creature_that_stayed_small() -> void:
	var mutant := put_battlefield(0, "Goblin Mutant")
	put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [mutant.id]))
