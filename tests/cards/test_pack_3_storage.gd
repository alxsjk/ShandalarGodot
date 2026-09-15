extends GameTest

class LastOption extends DecisionAgent:
	func answer_option(_g: MtgGame, _pid: int, _prompt: String, options: Array[String], _hint: int) -> int: return options.size() - 1

func before_each() -> void:
	CardPacks.set_enabled(IceAgePack.ID, true)
	super()
	advance_to_step(Mtg.Step.MAIN1)
func after_each() -> void:
	g = null
	CardPacks.set_enabled(IceAgePack.ID, false)

func test_amulet_uses_chosen_actual_color_not_a_free_mana_color() -> void:
	var amulet := put_battlefield(0, "Jeweled Amulet")
	add_mana(0, Mtg.ManaColor.R)
	add_mana(0, Mtg.ManaColor.G)
	g.agents[0] = LastOption.new()
	assert_ok(g.activate_ability(0, amulet, 0))
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.R), 1)
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.G), 0)
	resolve_stack()
	g.untap_permanent(amulet)
	assert_refused(g.activate_ability(0, amulet, 0))
	assert_ok(g.tap_for_mana(0, amulet, 0))
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.G), 1)
	assert_eq(int(amulet.counters.get("charge", 0)), 0)

func test_amulet_storage_cannot_follow_a_new_battlefield_incarnation() -> void:
	var amulet := put_battlefield(0, "Jeweled Amulet")
	add_mana(0, Mtg.ManaColor.U)
	assert_ok(g.activate_ability(0, amulet, 0))
	g.return_to_hand(amulet)
	g.put_from_hand_into_play(amulet, 0)
	resolve_stack()
	assert_eq(int(amulet.counters.get("charge", 0)), 0)
	assert_false(amulet.memory.has("stored_mana"))

func test_cauldron_stores_coupled_colors_only_for_the_exiled_card() -> void:
	var cauldron := put_battlefield(0, "Ice Cauldron")
	var bear := give_hand(0, "Grizzly Bears")
	add_mana(0, Mtg.ManaColor.C)
	add_mana(0, Mtg.ManaColor.G)
	assert_ok(g.activate_ability(0, cauldron, 0, [], 2))
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.EXILE)
	assert_true(g.can_play_from_exile(0, bear))
	g.untap_permanent(cauldron)
	assert_ok(g.tap_for_mana(0, cauldron, 0))
	var other := give_hand(0, "Grizzly Bears")
	assert_refused(g.cast_spell(0, other))
	assert_ok(g.cast_spell(0, bear))
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(g.players[0].mana_pool.total(), 0)

func test_cauldron_cast_permission_survives_source_leaving() -> void:
	var cauldron := put_battlefield(0, "Ice Cauldron")
	var bear := give_hand(0, "Grizzly Bears")
	assert_ok(g.activate_ability(0, cauldron, 0, [], 0))
	g.return_to_hand(cauldron)
	resolve_stack()
	assert_true(g.can_play_from_exile(0, bear))
	add_mana(0, Mtg.ManaColor.G, 2)
	assert_ok(g.cast_spell(0, bear))
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)

func test_sorcerer_refuses_wrong_color_before_costs() -> void:
	var sorcerer := put_battlefield(0, "Krovikan Sorcerer")
	var island := give_hand(0, "Island")
	assert_refused(g.activate_ability(0, sorcerer, 1))
	assert_false(sorcerer.tapped)
	assert_eq(island.zone, Mtg.Zone.HAND)
	assert_ok(g.activate_ability(0, sorcerer, 0))
	assert_eq(island.zone, Mtg.Zone.GRAVEYARD)
	resolve_stack()
	assert_eq(g.players[0].hand.size(), 1)

func test_sorcerer_black_discards_only_one_of_the_two_drawn_cards() -> void:
	var sorcerer := put_battlefield(0, "Krovikan Sorcerer")
	var black := give_hand(0, "Dark Ritual")
	var existing := give_hand(0, "Island")
	assert_ok(g.activate_ability(0, sorcerer, 1))
	assert_eq(black.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(existing.zone, Mtg.Zone.HAND)
	resolve_stack()
	assert_eq(existing.zone, Mtg.Zone.HAND)
	assert_eq(g.players[0].drawn_this_turn.size(), 2)
	assert_eq(g.players[0].hand.size(), 2)
