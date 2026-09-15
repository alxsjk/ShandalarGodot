extends GameTest
## Real casts, targets and costs, including the distinction between damage
## prevented and damage actually dealt. These tests do not bypass resolve.

func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()
	advance_to_step(Mtg.Step.MAIN1)

func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)

func cast(name: String, targets: Array = [], x := 0) -> CardInstance:
	var card := give_hand(0, name)
	for color in [Mtg.ManaColor.W, Mtg.ManaColor.U, Mtg.ManaColor.B, Mtg.ManaColor.R, Mtg.ManaColor.G]: add_mana(0, color, 15)
	assert_ok(g.cast_spell(0, card, targets, x))
	resolve_stack()
	return card

func test_brainstorm_net_card_and_library_counts() -> void:
	var before := g.players[0].library.size()
	cast("Brainstorm")
	assert_eq(g.players[0].hand.size(), 1)
	assert_eq(g.players[0].library.size(), before - 1)

func test_diabolic_vision_takes_exactly_one_without_shuffle() -> void:
	var before: Array[CardInstance] = g.players[0].library.duplicate()
	cast("Diabolic Vision")
	assert_eq(g.players[0].hand.size(), 1)
	assert_eq(g.players[0].library.size(), before.size() - 1)
	for i in before.size() - 5: assert_eq(g.players[0].library[i], before[i])

func test_natures_lore_gets_a_nonbasic_forest_untapped() -> void:
	g.players[0].library.clear()
	var dual := _make_instance(0, "Tropical Island")
	dual.zone = Mtg.Zone.LIBRARY
	g.players[0].library.append(dual)
	cast("Nature's Lore")
	assert_eq(dual.zone, Mtg.Zone.BATTLEFIELD)
	assert_false(dual.tapped)

func test_incinerate_bans_regeneration_when_it_deals_damage() -> void:
	var troll := put_battlefield(1, "Sedge Troll")
	put_battlefield(1, "Swamp")
	troll.regeneration_shields = 1
	cast("Incinerate", [TargetRef.card(troll)])
	assert_eq(troll.zone, Mtg.Zone.GRAVEYARD)

func test_fully_prevented_incinerate_does_not_ban_regeneration() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	PreventDamageEffect.new(3).target_creature().resolve(g, bear, 1, TargetRef.card(bear))
	cast("Incinerate", [TargetRef.card(bear)])
	assert_eq(bear.damage, 0)
	assert_false(bear.regeneration_banned_this_turn)

func test_hydroblast_allows_a_nonred_target_but_does_not_destroy_it() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	var card := give_hand(0, "Hydroblast")
	add_mana(0, Mtg.ManaColor.U)
	assert_ok(g.cast_spell(0, card, [TargetRef.card(bear)], 0, 1))
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)

func test_pyroblast_destroys_blue_permanent() -> void:
	var flyer := put_battlefield(1, "Air Elemental")
	var card := give_hand(0, "Pyroblast")
	add_mana(0, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(0, card, [TargetRef.card(flyer)], 0, 1))
	resolve_stack()
	assert_eq(flyer.zone, Mtg.Zone.GRAVEYARD)

func test_word_of_undoing_saves_only_your_white_auras() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	var armor := give_hand(0, "Armor of Faith")
	var red := give_hand(0, "Stonehands")
	g.attach_aura_from_anywhere(armor, bear, 0)
	g.attach_aura_from_anywhere(red, bear, 0)
	cast("Word of Undoing", [TargetRef.card(bear)])
	assert_eq(bear.zone, Mtg.Zone.HAND)
	assert_eq(armor.zone, Mtg.Zone.HAND)
	assert_eq(red.zone, Mtg.Zone.GRAVEYARD)

func test_word_of_blasting_damages_controller_not_owner() -> void:
	var wall := put_battlefield(0, "Wall of Stone")
	g.change_control(wall, 1)
	cast("Word of Blasting", [TargetRef.card(wall)])
	assert_eq(wall.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[1].life, 17)
	assert_eq(g.players[0].life, 20)

func test_battle_frenzy_only_yours_and_different_green_bonus() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	var goblin := put_battlefield(0, "Mons's Goblin Raiders")
	var other := put_battlefield(1, "Grizzly Bears")
	cast("Battle Frenzy")
	assert_eq(Vector2i(bear.cur_power, bear.cur_toughness), Vector2i(3, 3))
	assert_eq(Vector2i(goblin.cur_power, goblin.cur_toughness), Vector2i(2, 1))
	assert_eq(Vector2i(other.cur_power, other.cur_toughness), Vector2i(2, 2))

func test_panic_has_real_timing_and_block_restriction() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	var attacker := put_battlefield(0, "Grizzly Bears")
	var panic := give_hand(0, "Panic")
	add_mana(0, Mtg.ManaColor.R)
	assert_refused(g.cast_spell(0, panic, [TargetRef.card(bear)]), "combat")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	add_mana(0, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(0, panic, [TargetRef.card(bear)]))
	resolve_stack()
	assert_ne(CombatState.block_illegality(g, bear, attacker, 1), "")

func test_stunted_growth_short_hand_moves_every_card() -> void:
	give_hand(1, "Forest")
	give_hand(1, "Mountain")
	var before := g.players[1].library.size()
	cast("Stunted Growth", [TargetRef.player(1)])
	assert_eq(g.players[1].hand.size(), 0)
	assert_eq(g.players[1].library.size(), before + 2)

func test_delayed_cantrip_is_visible_to_ai_intent() -> void:
	var intent := EffectIntent.read(CardRegistry.get_card("Flare").spell_effects, "Flare")
	assert_eq(intent.damage, 1)
	assert_eq(intent.draws, 1)
	assert_false(intent.unknown)

func test_songs_counts_creatures_not_artifacts_or_lands() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	var ring := put_battlefield(0, "Sol Ring")
	g.sacrifice_permanent(bear)
	g.sacrifice_permanent(ring)
	var card := give_hand(0, "Songs of the Damned")
	add_mana(0, Mtg.ManaColor.B)
	assert_ok(g.cast_spell(0, card))
	resolve_stack()
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.B), 1)
