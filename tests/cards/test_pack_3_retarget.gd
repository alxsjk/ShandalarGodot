extends GameTest

func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()
	advance_to_step(Mtg.Step.MAIN1)
func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)

func test_deflection_redirects_bolt_and_updates_resolution_groups() -> void:
	var bolt := give_hand(1, "Lightning Bolt")
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(1, bolt, [TargetRef.player(0)]))
	var redirect := give_hand(0, "Deflection")
	g.priority_player = 0
	add_mana(0, Mtg.ManaColor.U, 4)
	assert_ok(g.cast_spell(0, redirect, [TargetRef.card(bolt)]))
	resolve_stack()
	assert_eq(g.players[0].life, 20)
	assert_eq(g.players[1].life, 17)

func test_deflection_rejects_a_multi_target_spell_before_payment() -> void:
	var a := put_battlefield(0, "Grizzly Bears")
	var b := put_battlefield(1, "Grizzly Bears")
	var spell := give_hand(1, "Pyrotechnics")
	g.priority_player = 1
	g.active_player = 1
	add_mana(1, Mtg.ManaColor.R, 5)
	var ra := TargetRef.card(a)
	var rb := TargetRef.card(b)
	ra.amount = 2
	rb.amount = 2
	assert_ok(g.cast_spell(1, spell, [ra, rb]))
	g.priority_player = 0
	var redirect := give_hand(0, "Deflection")
	add_mana(0, Mtg.ManaColor.U, 4)
	assert_refused(g.cast_spell(0, redirect, [TargetRef.card(spell)]))
	assert_eq(g.players[0].mana_pool.total(), 4)

func test_retarget_preserves_original_spell_restrictions() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	var black := put_battlefield(1, "Black Knight")
	var terror := give_hand(1, "Terror")
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.B, 2)
	assert_ok(g.cast_spell(1, terror, [TargetRef.card(bear)]))
	assert_false(g.retarget_spell(terror, 0, TargetRef.card(black)))
	assert_eq(g.find_stack_item(terror).targets[0].instance_id, bear.id)

func test_deflection_can_redirect_counterspell_to_itself_while_resolving() -> void:
	var bear := give_hand(0, "Grizzly Bears")
	add_mana(0, Mtg.ManaColor.G, 2)
	assert_ok(g.cast_spell(0, bear))
	var counter := give_hand(1, "Counterspell")
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.U, 2)
	assert_ok(g.cast_spell(1, counter, [TargetRef.card(bear)]))
	var redirect := give_hand(0, "Deflection")
	g.priority_player = 0
	add_mana(0, Mtg.ManaColor.U, 4)
	assert_ok(g.cast_spell(0, redirect, [TargetRef.card(counter)]))
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(counter.zone, Mtg.Zone.GRAVEYARD)

func test_ai_redirects_a_hostile_bolt_using_public_targets() -> void:
	var bolt := give_hand(1, "Lightning Bolt")
	g.priority_player = 1
	add_mana(1, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(1, bolt, [TargetRef.player(0)]))
	g.priority_player = 0
	give_hand(0, "Deflection")
	add_mana(0, Mtg.ManaColor.U, 4)
	var ai := AiPlayer.new(0, AiProfile.wizard())
	g.agents[0] = ai
	assert_eq(ai._respond_action(g), "cast Deflection")
	resolve_stack()
	assert_eq(g.players[0].life, 20)
	assert_eq(g.players[1].life, 17)
