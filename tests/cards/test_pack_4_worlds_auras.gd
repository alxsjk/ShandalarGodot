extends GameTest

func before_each() -> void:
	CardPacks.set_enabled("pack-4", true)
	super()
	advance_to_step(Mtg.Step.MAIN1)

func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-4", false)

func enchant(name: String, host: CardInstance) -> CardInstance:
	var aura := give_hand(0, name)
	for color in Mtg.WUBRG: add_mana(0, color, 12)
	assert_ok(g.cast_spell(0, aura, [TargetRef.card(host)]))
	resolve_stack()
	return aura

func test_aether_storm_bans_both_players_creatures_and_opponent_can_pay_life() -> void:
	var storm := put_battlefield(0, "Aether Storm")
	var bear := give_hand(0, "Grizzly Bears")
	add_mana(0, Mtg.ManaColor.G, 2)
	assert_refused(g.cast_spell(0, bear))
	assert_ok(g.pass_priority(0))
	assert_ok(g.activate_ability(1, storm, 0))
	assert_eq(g.players[1].life, 16)
	resolve_stack()
	assert_eq(storm.zone, Mtg.Zone.GRAVEYARD)
	assert_ok(g.cast_spell(0, bear))

func test_autumn_shroud_permission_is_one_player_only_and_expires() -> void:
	var willow := put_battlefield(0, "Autumn Willow")
	var ours := give_hand(0, "Giant Growth")
	var theirs := give_hand(1, "Giant Growth")
	var spec := TargetSpec.creature()
	assert_false(spec.is_legal(g, TargetRef.card(willow), ours))
	assert_false(spec.is_legal(g, TargetRef.card(willow), theirs))
	add_mana(0, Mtg.ManaColor.G)
	assert_ok(g.activate_ability(0, willow, 0, [TargetRef.player(0)]))
	resolve_stack()
	assert_true(willow.cur_shroud)
	assert_true(spec.is_legal(g, TargetRef.card(willow), ours))
	assert_false(spec.is_legal(g, TargetRef.card(willow), theirs))
	advance_to_next_turn()
	assert_false(spec.is_legal(g, TargetRef.card(willow), ours))

func test_feroz_and_irini_tax_only_the_named_spell_types() -> void:
	put_battlefield(0, "Feroz's Ban")
	put_battlefield(1, "Irini Sengir")
	assert_eq(g.spell_surcharge(0, CardRegistry.get_card("Grizzly Bears")), 2)
	assert_eq(g.spell_surcharge(1, CardRegistry.get_card("Carapace")), 2)
	assert_eq(g.spell_surcharge(0, CardRegistry.get_card("Serra Bestiary")), 2)
	assert_eq(g.spell_surcharge(0, CardData.new("GW Aura", "{G}{W}", Mtg.CardType.ENCHANTMENT)), 2)
	assert_eq(g.spell_surcharge(1, CardRegistry.get_card("Lightning Bolt")), 0)

func test_carapace_stats_and_sacrifice_regeneration_survive_aura_departure() -> void:
	var bear := put_battlefield(0, "Grizzly Bears")
	var aura := enchant("Carapace", bear)
	assert_eq(bear.cur_toughness, 4)
	assert_ok(g.activate_ability(0, aura, 0))
	assert_eq(aura.zone, Mtg.Zone.GRAVEYARD)
	resolve_stack()
	g.destroy(bear)
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_true(bear.tapped)
	assert_eq(bear.cur_toughness, 2)

func test_feast_and_torture_have_permanent_and_counter_stats() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	enchant("Feast of the Unicorn", bear)
	assert_eq(bear.cur_power, 6)
	var aura := enchant("Torture", bear)
	assert_ok(g.activate_ability(0, aura, 0))
	resolve_stack()
	assert_eq(int(bear.counters.get("-1/-1", 0)), 1)
	assert_eq(bear.cur_toughness, 1)

func test_roots_targets_only_nonfliers_taps_and_stops_normal_untap() -> void:
	var bird := put_battlefield(1, "Mesa Falcon")
	var bear := put_battlefield(1, "Grizzly Bears")
	var aura := give_hand(0, "Roots")
	add_mana(0, Mtg.ManaColor.G, 4)
	assert_refused(g.cast_spell(0, aura, [TargetRef.card(bird)]))
	assert_ok(g.cast_spell(0, aura, [TargetRef.card(bear)]))
	resolve_stack()
	assert_true(bear.tapped)
	advance_to_next_turn()
	assert_true(bear.tapped)
	g.untap_permanent(bear)
	assert_false(bear.tapped)

func test_bestiary_forbids_t_symbol_mana_and_activated_but_not_other_costs() -> void:
	var elf := put_battlefield(0, "Llanowar Elves")
	enchant("Serra Bestiary", elf)
	assert_refused(g.tap_for_mana(0, elf))
	assert_false(elf.tapped)
	var thopter := put_battlefield(0, "Roterothopter")
	enchant("Serra Bestiary", thopter)
	assert_ok(g.activate_ability(0, thopter, 0))
	resolve_stack()
	assert_eq(thopter.cur_power, 1)
	var shaman := put_battlefield(0, "Anaba Shaman")
	enchant("Serra Bestiary", shaman)
	assert_refused(g.activate_ability(0, shaman, 0, [TargetRef.player(1)]))
	assert_true(thopter.cur_cant_attack)

func test_aysen_highway_and_mystic_decree_apply_live_keyword_changes() -> void:
	var bird := put_battlefield(1, "Mesa Falcon")
	put_battlefield(0, "Aysen Highway")
	assert_has(bird.cur_landwalk, "plains")
	put_battlefield(0, "Mystic Decree")
	assert_false(bird.has_keyword(Mtg.Keyword.FLYING))
	assert_has(bird.cur_landwalk, "plains")

func test_apocalypse_chime_destroys_original_homelands_not_original_or_tokens() -> void:
	var chime := put_battlefield(0, "Apocalypse Chime")
	var land := put_battlefield(1, "Aysen Abbey")
	var bear := put_battlefield(1, "Grizzly Bears")
	var token := g.create_token(1, CardRegistry.get_card("Mesa Falcon"))[0]
	add_mana(0, Mtg.ManaColor.C, 2)
	assert_ok(g.activate_ability(0, chime, 0))
	assert_eq(chime.zone, Mtg.Zone.GRAVEYARD)
	resolve_stack()
	assert_eq(land.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(token.zone, Mtg.Zone.BATTLEFIELD)

func test_koskun_attack_tax_is_aggregated_before_any_mana_is_spent() -> void:
	put_battlefield(1, "Koskun Falls")
	var a := put_battlefield(0, "Grizzly Bears")
	var b := put_battlefield(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	add_mana(0, Mtg.ManaColor.C, 2)
	assert_refused(g.declare_attackers(0, [a.id, b.id]))
	assert_eq(g.players[0].mana_pool.total(), 2)
	assert_false(a.tapped)
	add_mana(0, Mtg.ManaColor.C, 2)
	assert_ok(g.declare_attackers(0, [a.id, b.id]))
	assert_eq(g.players[0].mana_pool.total(), 0)
