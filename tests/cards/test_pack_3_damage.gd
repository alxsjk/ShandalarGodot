extends GameTest

func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()
	advance_to_step(Mtg.Step.MAIN1)

func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)

func test_energy_storm_prevents_spell_but_not_creature_ability_damage() -> void:
	put_battlefield(0, "Energy Storm")
	var spell := give_hand(0, "Lightning Bolt")
	add_mana(0, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(0, spell, [TargetRef.player(1)]))
	resolve_stack()
	assert_eq(g.players[1].life, 20)
	var wizard := put_battlefield(0, "Zuran Spellcaster")
	assert_ok(g.activate_ability(0, wizard, 0, [TargetRef.player(1)]))
	resolve_stack()
	assert_eq(g.players[1].life, 19)

func test_classic_queued_damage_remembers_it_came_from_a_spell() -> void:
	put_battlefield(0, "Energy Storm")
	var spell := give_hand(0, "Lightning Bolt")
	spell.zone = Mtg.Zone.STACK
	var packet := g._plan_damage(spell, TargetRef.player(1), 3, false)
	spell.zone = Mtg.Zone.GRAVEYARD
	assert_true(packet.source_was_spell)
	assert_eq(g._land_damage(packet), 0)
	assert_eq(g.players[1].life, 20)

func test_lava_burst_cannot_be_prevented_to_creature_but_bolt_afterwards_can() -> void:
	var wall := put_battlefield(1, "Wall of Stone")
	PreventDamageEffect.new(8).target_creature().resolve(g, wall, 1, TargetRef.card(wall))
	var lava := give_hand(0, "Lava Burst")
	add_mana(0, Mtg.ManaColor.R, 5)
	assert_ok(g.cast_spell(0, lava, [TargetRef.card(wall)], 3))
	resolve_stack()
	assert_eq(wall.damage, 3)
	assert_eq(wall.prevention, 8)
	var bolt := give_hand(0, "Lightning Bolt")
	assert_ok(g.cast_spell(0, bolt, [TargetRef.card(wall)]))
	resolve_stack()
	assert_eq(wall.damage, 3)
	assert_eq(wall.prevention, 5)

func test_lava_burst_to_player_remains_preventable() -> void:
	PreventDamageEffect.new(3).to_controller().resolve(g, put_battlefield(1, "Grizzly Bears"), 1, null)
	var lava := give_hand(0, "Lava Burst")
	add_mana(0, Mtg.ManaColor.R, 4)
	assert_ok(g.cast_spell(0, lava, [TargetRef.player(1)], 3))
	resolve_stack()
	assert_eq(g.players[1].life, 20)

func test_lava_burst_ignores_energy_storm_for_creature_only() -> void:
	put_battlefield(0, "Energy Storm")
	var bear := put_battlefield(1, "Grizzly Bears")
	var lava := give_hand(0, "Lava Burst")
	add_mana(0, Mtg.ManaColor.R, 3)
	assert_ok(g.cast_spell(0, lava, [TargetRef.card(bear)], 2))
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
