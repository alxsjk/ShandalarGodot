extends GameTest
## Real costs, targets, live characteristics and expiry for Homelands.

func before_each() -> void:
	CardPacks.set_enabled("pack-4", true)
	super()

func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-4", false)

func test_keyword_creatures_use_exact_printed_stats_and_abilities() -> void:
	for row in HomelandsPack.records():
		if not load("res://cards/sets/hml/_rules.gd").VANILLA.has(row.name): continue
		var card := CardRegistry.get_card(row.name)
		assert_eq(card.power, int(row.power), row.name)
		assert_eq(card.toughness, int(row.toughness), row.name)
		assert_eq(card.oracle_text, String(row.oracle_text), row.name)
	assert_true(put_battlefield(0, "Ambush Party").has_keyword(Mtg.Keyword.HASTE))
	assert_true(put_battlefield(0, "Sea Sprite").has_keyword(Mtg.Keyword.FLYING))

func test_township_mana_charges_before_tapping_and_planner_can_use_it() -> void:
	var land := put_battlefield(0, "An-Havva Township")
	assert_refused(g.tap_for_mana(0, land, 1))
	assert_false(land.tapped)
	put_battlefield(0, "Island")
	assert_true(g.try_pay(0, ManaCost.parse("{G}")))
	assert_true(land.tapped)
	assert_eq(g.players[0].mana_pool.total(), 0)

func test_all_five_filter_lands_have_four_correct_outputs() -> void:
	var expected := {"An-Havva Township": [Mtg.ManaColor.G, Mtg.ManaColor.R, Mtg.ManaColor.W],
		"Aysen Abbey": [Mtg.ManaColor.W, Mtg.ManaColor.G, Mtg.ManaColor.U],
		"Castle Sengir": [Mtg.ManaColor.B, Mtg.ManaColor.U, Mtg.ManaColor.R],
		"Koskun Keep": [Mtg.ManaColor.R, Mtg.ManaColor.B, Mtg.ManaColor.G],
		"Wizards' School": [Mtg.ManaColor.U, Mtg.ManaColor.W, Mtg.ManaColor.B]}
	for name in expected:
		var land := put_battlefield(0, name)
		for index in 4:
			g.players[0].mana_pool.clear()
			g.untap_permanent(land)
			add_mana(0, Mtg.ManaColor.C, 0 if index == 0 else (1 if index == 1 else 2))
			assert_ok(g.tap_for_mana(0, land, index))
			var color: int = Mtg.ManaColor.C if index == 0 else expected[name][index - 1]
			assert_eq(g.players[0].mana_pool.amount_of(color), 1, name)
			assert_eq(g.players[0].mana_pool.total(), 1, name)

func test_abbey_matron_pays_white_taps_and_loses_bonus_at_cleanup() -> void:
	var matron := put_battlefield(0, "Abbey Matron")
	add_mana(0, Mtg.ManaColor.W)
	assert_ok(g.activate_ability(0, matron, 0))
	resolve_stack()
	assert_true(matron.tapped)
	assert_eq(matron.cur_toughness, 6)
	advance_to_next_turn()
	assert_eq(matron.cur_toughness, 3)

func test_anaba_ancestor_requires_another_minotaur_and_shaman_deals_damage() -> void:
	var ancestor := put_battlefield(0, "Anaba Ancestor")
	var shaman := put_battlefield(0, "Anaba Shaman")
	assert_refused(g.activate_ability(0, ancestor, 0, [TargetRef.card(ancestor)]))
	assert_false(ancestor.tapped)
	assert_ok(g.activate_ability(0, ancestor, 0, [TargetRef.card(shaman)]))
	resolve_stack()
	assert_eq(shaman.cur_power, 3)
	add_mana(0, Mtg.ManaColor.R)
	assert_ok(g.activate_ability(0, shaman, 0, [TargetRef.player(1)]))
	resolve_stack()
	assert_eq(g.players[1].life, 19)

func test_chandler_and_joven_enforce_opposite_artifact_targets() -> void:
	var chandler := put_battlefield(0, "Chandler")
	var joven := put_battlefield(0, "Joven")
	var creature := put_battlefield(1, "Clockwork Gnomes")
	var ring := put_battlefield(1, "Sol Ring")
	add_mana(0, Mtg.ManaColor.R, 6)
	assert_refused(g.activate_ability(0, chandler, 0, [TargetRef.card(ring)]))
	assert_refused(g.activate_ability(0, joven, 0, [TargetRef.card(creature)]))
	assert_ok(g.activate_ability(0, chandler, 0, [TargetRef.card(creature)]))
	resolve_stack()
	assert_eq(creature.zone, Mtg.Zone.GRAVEYARD)
	assert_ok(g.activate_ability(0, joven, 0, [TargetRef.card(ring)]))
	resolve_stack()
	assert_eq(ring.zone, Mtg.Zone.GRAVEYARD)

func test_roterothopter_limit_and_beast_walkers_banding() -> void:
	var thopter := put_battlefield(0, "Roterothopter")
	var walkers := put_battlefield(0, "Beast Walkers")
	add_mana(0, Mtg.ManaColor.C, 6)
	for i in 2:
		assert_ok(g.activate_ability(0, thopter, 0))
		resolve_stack()
	assert_eq(thopter.cur_power, 2)
	assert_refused(g.activate_ability(0, thopter, 0))
	assert_eq(g.players[0].mana_pool.total(), 2)
	add_mana(0, Mtg.ManaColor.G)
	assert_ok(g.activate_ability(0, walkers, 0))
	resolve_stack()
	assert_true(walkers.has_keyword(Mtg.Keyword.BANDING))

func test_grandmother_kills_with_toughness_loss_not_damage() -> void:
	var grandmother := put_battlefield(0, "Grandmother Sengir")
	var bird := put_battlefield(1, "Mesa Falcon")
	RegenerateEffect.new().resolve(g, bird, 1, null)
	add_mana(0, Mtg.ManaColor.B, 2)
	assert_ok(g.activate_ability(0, grandmother, 0, [TargetRef.card(bird)]))
	resolve_stack()
	assert_eq(bird.zone, Mtg.Zone.GRAVEYARD)

func test_live_counts_and_global_tribal_lords() -> void:
	var constable := put_battlefield(0, "An-Havva Constable")
	assert_eq(constable.cur_toughness, 2)
	var bear := put_battlefield(1, "Grizzly Bears")
	assert_eq(constable.cur_toughness, 3)
	g.destroy(bear)
	assert_eq(constable.cur_toughness, 2)
	var crusader := put_battlefield(0, "Aysen Crusader")
	put_battlefield(0, "Pikemen")
	assert_eq(crusader.cur_power, 3)

func test_craft_lord_and_soraya_count_opponents_too() -> void:
	var minotaur := put_battlefield(1, "Anaba Bodyguard")
	put_battlefield(0, "Anaba Spirit Crafter")
	assert_eq(minotaur.cur_power, 3)
	var bird := put_battlefield(1, "Mesa Falcon")
	put_battlefield(0, "Soraya the Falconer")
	assert_eq(bird.cur_power, 2)
	assert_eq(bird.cur_toughness, 2)

func test_sengir_death_rewards_are_counters_and_baron_targets_other_vampires() -> void:
	var baron := put_battlefield(0, "Baron Sengir")
	var bats := put_battlefield(0, "Sengir Bats")
	var bear := put_battlefield(1, "Grizzly Bears")
	g.deal_damage(bats, TargetRef.card(bear), 1)
	g.deal_damage(baron, TargetRef.card(bear), 1)
	resolve_stack()
	assert_eq(int(baron.counters.get("+2/+2", 0)), 1)
	assert_eq(int(bats.counters.get("+1/+1", 0)), 1)
	assert_refused(g.activate_ability(0, baron, 0, [TargetRef.card(baron)]))
