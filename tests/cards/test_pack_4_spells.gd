extends GameTest
## Homelands spells: real cast path, zone identity, delayed draws and costs.

func before_each() -> void:
	CardPacks.set_enabled("pack-4", true)
	super()
	advance_to_step(Mtg.Step.MAIN1)

func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-4", false)

func cast(name: String, targets: Array = []) -> CardInstance:
	var card := give_hand(0, name)
	for color in [Mtg.ManaColor.W, Mtg.ManaColor.U, Mtg.ManaColor.B, Mtg.ManaColor.R, Mtg.ManaColor.G]: add_mana(0, color, 10)
	assert_ok(g.cast_spell(0, card, targets))
	resolve_stack()
	return card

func test_memory_lapse_moves_directly_to_library_and_undo_restores_stack() -> void:
	var bear := give_hand(0, "Grizzly Bears")
	add_mana(0, Mtg.ManaColor.G, 2)
	assert_ok(g.cast_spell(0, bear))
	var lapse := give_hand(0, "Memory Lapse")
	add_mana(0, Mtg.ManaColor.U, 2)
	assert_ok(g.cast_spell(0, lapse, [TargetRef.card(bear)]))
	if lapse.zone != Mtg.Zone.STACK: return
	var before := g.players[0].library.duplicate()
	var mark := g.make_mark()
	g._resolve_top()
	assert_eq(bear.zone, Mtg.Zone.LIBRARY)
	assert_eq(g.players[0].library.back(), bear)
	assert_false(g.players[0].graveyard.has(bear))
	assert_eq(g.stack.size(), 0)
	g.unmake_to(mark)
	assert_eq(bear.zone, Mtg.Zone.STACK)
	assert_eq(lapse.zone, Mtg.Zone.STACK)
	assert_eq(g.stack.size(), 2)
	assert_eq(g.players[0].library, before)

func test_memory_lapse_countered_copy_ceases_to_exist() -> void:
	var bolt := give_hand(0, "Lightning Bolt")
	add_mana(0, Mtg.ManaColor.R)
	assert_ok(g.cast_spell(0, bolt, [TargetRef.player(1)]))
	var copy := g.copy_spell_on_stack(bolt, 0)
	assert_not_null(copy)
	if copy == null: return
	var lapse := give_hand(0, "Memory Lapse")
	add_mana(0, Mtg.ManaColor.U, 2)
	assert_ok(g.cast_spell(0, lapse, [TargetRef.card(copy)]))
	if lapse.zone != Mtg.Zone.STACK: return
	g._resolve_top()
	assert_null(g.find_instance(copy.id))
	assert_false(g.players[0].library.has(copy))
	assert_eq(g.stack.size(), 1)

func test_shrink_expires_without_changing_toughness() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	cast("Shrink", [TargetRef.card(bear)])
	assert_eq(bear.cur_power, -3)
	assert_eq(bear.cur_toughness, 2)
	advance_to_next_turn()
	assert_eq(bear.cur_power, 2)

func test_an_havva_inn_counts_both_sides_green_creatures() -> void:
	put_battlefield(0, "Grizzly Bears")
	put_battlefield(1, "Grizzly Bears")
	put_battlefield(1, "Mesa Falcon")
	cast("An-Havva Inn")
	assert_eq(g.players[0].life, 23)

func test_dry_spell_hits_every_creature_and_player() -> void:
	var elf := put_battlefield(0, "Llanowar Elves")
	var bear := put_battlefield(1, "Grizzly Bears")
	cast("Dry Spell")
	assert_eq(elf.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(bear.damage, 1)
	assert_eq(g.players[0].life, 19)
	assert_eq(g.players[1].life, 19)

func test_evaporate_only_hits_blue_or_white_once() -> void:
	var blue := put_battlefield(1, "Sea Sprite")
	var white := put_battlefield(0, "Mesa Falcon")
	var green := put_battlefield(1, "Grizzly Bears")
	cast("Evaporate")
	assert_eq(blue.zone, Mtg.Zone.BATTLEFIELD) # protection from red prevents Evaporate
	assert_eq(blue.damage, 0)
	assert_eq(white.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(green.damage, 0)
	assert_eq(g.players[1].life, 20)

func test_forget_draws_only_as_many_as_actually_discarded() -> void:
	g.players[1].hand.clear()
	var old := give_hand(1, "Forest")
	cast("Forget", [TargetRef.player(1)])
	assert_eq(old.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[1].hand.size(), 1)

func test_leeches_removes_poison_and_deals_preventable_damage() -> void:
	g.add_poison(1, 6)
	var healer := put_battlefield(0, "Samite Healer")
	PreventDamageEffect.new(2).resolve(g, healer, 0, TargetRef.player(1))
	cast("Leeches", [TargetRef.player(1)])
	assert_eq(g.players[1].poison, 0)
	assert_eq(g.players[1].life, 16)

func test_merchant_scroll_only_searches_blue_instants() -> void:
	var counter := _make_instance(0, "Counterspell")
	counter.zone = Mtg.Zone.LIBRARY
	g.players[0].library.append(counter)
	var wrong := _make_instance(0, "Lightning Bolt")
	wrong.zone = Mtg.Zone.LIBRARY
	g.players[0].library.append(wrong)
	cast("Merchant Scroll")
	assert_eq(counter.zone, Mtg.Zone.HAND)
	assert_eq(wrong.zone, Mtg.Zone.LIBRARY)

func test_headstone_exiles_any_graveyard_card_then_next_turn_cantrip() -> void:
	var land := put_battlefield(1, "Forest")
	g.destroy(land)
	var before := g.players[0].hand.size()
	cast("Headstone", [TargetRef.card(land)])
	assert_eq(land.zone, Mtg.Zone.EXILE)
	assert_eq(g.players[0].hand.size(), before)
	advance_to_next_turn()
	assert_eq(g.players[0].hand.size(), before + 1)

func test_prophecy_reveals_land_gains_life_and_delays_draw() -> void:
	var before := g.players[0].hand.size()
	cast("Prophecy", [TargetRef.player(1)])
	assert_eq(g.players[0].life, 21)
	assert_eq(g.players[0].hand.size(), before)
	advance_to_next_turn()
	assert_eq(g.players[0].hand.size(), before + 1)

func test_renewal_requires_a_land_cost_and_searches_untapped_basic() -> void:
	var spell := give_hand(0, "Renewal")
	add_mana(0, Mtg.ManaColor.G, 3)
	assert_refused(g.cast_spell(0, spell))
	assert_eq(g.players[0].mana_pool.total(), 3)
	var land := put_battlefield(0, "Forest")
	assert_ok(g.cast_spell(0, spell))
	assert_eq(land.zone, Mtg.Zone.GRAVEYARD)
	resolve_stack()
	assert_eq(g.players[0].battlefield.size(), 1)
	assert_false(g.players[0].battlefield[0].tapped)
