extends GameTest
## Exercise the real shared screen against filtered pack-card views.

var referee: SgPracticeMatch
var revision := 1
var refusals: Array = []

func before_each() -> void:
	CardPacks.set_enabled("pack-3", true)
	CardPacks.set_enabled("pack-5", true)
	super()
	referee = SgPracticeMatch.new(42)
	referee.game = g
	g.interactive_choices = true
	g.set_agent(0, HumanAgent.new())
	g.set_agent(1, HumanAgent.new())
	revision = 1
	refusals.clear()

func after_each() -> void:
	referee = null
	g = null
	CardPacks.set_enabled("pack-3", false)
	CardPacks.set_enabled("pack-5", false)

func _room() -> Dictionary:
	return {"id": "r1", "name": "Pack screen", "seat": 0, "names": ["One", "Two"],
		"revision": revision, "ready": [true, true], "connected": [true, true],
		"game": referee.view(0), "deck_names": referee.deck_names.duplicate(), "deck": {}}

func _screen() -> SgDuelView:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 600)
	add_child_autofree(viewport)
	var screen := SgDuelView.new()
	screen.stops.from_masks(PackedInt32Array([255, 255, 255, 255]))
	viewport.add_child(screen)
	screen.action_requested.connect(func(action: Dictionary) -> void:
		var error := referee.act(0, action)
		if not error.is_empty():
			refusals.append(error)
			screen.show_notice(error)
		else: revision += 1
		screen.present.call_deferred(_room(), true, false))
	screen.present(_room(), true, false)
	return screen

func _local(screen: SgDuelView, card: CardInstance) -> CardInstance:
	return screen.game.find_instance(screen.projection.local_id(referee._handle(0, card)))

func _pump() -> void:
	for i in 8: await get_tree().process_frame

func test_exile_pile_click_announces_and_casts_bottle_spell() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var bear := give_hand(0, "Grizzly Bears")
	g.put_from_hand_on_top_of_library(bear)
	g.exile_library_card(bear)
	g.grant_exile_play(bear, 0, true)
	add_mana(0, Mtg.ManaColor.G, 2)
	var screen := _screen()
	screen._on_graveyard_card(_local(screen, bear))
	await _pump()
	assert_eq(refusals, [])
	assert_eq(bear.zone, Mtg.Zone.STACK)

func test_graveyard_menu_dispatches_ashen_ghoul() -> void:
	var ghoul := put_battlefield(0, "Ashen Ghoul")
	g.sacrifice_permanent(ghoul)
	for i in 3: g.sacrifice_permanent(put_battlefield(0, "Grizzly Bears"))
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.UPKEEP)
	add_mana(0, Mtg.ManaColor.B)
	var screen := _screen()
	screen._on_graveyard_card(_local(screen, ghoul))
	assert_eq(screen._ability_menu.item_count, 1)
	screen._on_ability_chosen(0)
	await _pump()
	assert_eq(refusals, [])
	assert_eq(g.stack.size(), 1)
	resolve_stack()
	assert_eq(ghoul.zone, Mtg.Zone.BATTLEFIELD)

func test_hand_mana_menu_exiles_spirit_guide() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var guide := give_hand(0, "Elvish Spirit Guide")
	var screen := _screen()
	screen._open_ability_menu(_local(screen, guide), true)
	await _pump()
	assert_eq(refusals, [])
	assert_eq(guide.zone, Mtg.Zone.EXILE)
	assert_eq(g.players[0].mana_pool.total_of(Mtg.ManaColor.G), 1)

func test_melee_player_selects_enemy_blockers_in_shared_screen() -> void:
	var attacker := put_battlefield(0, "Hill Giant")
	var blocker := put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [attacker.id]))
	var melee := give_hand(0, "Melee")
	add_mana(0, Mtg.ManaColor.R, 5)
	assert_ok(g.cast_spell(0, melee))
	resolve_stack()
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	var screen := _screen()
	assert_eq(screen.mode, DuelScreen.Mode.BLOCKERS)
	screen._on_card_clicked(_local(screen, blocker))
	screen._on_card_clicked(_local(screen, attacker))
	screen._on_confirm()
	await _pump()
	if g.awaiting_blockers:
		screen._on_confirm()
		await _pump()
	assert_eq(refusals, [])
	assert_false(g.awaiting_blockers)
	assert_eq(g.combat.blocks.get(blocker.id), attacker.id)
