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
	screen._open_card_menu(_local(screen, guide), Vector2(200, 200))
	assert_gte(screen._card_menu.get_item_index(DuelScreen.CARD_MENU_HAND_MANA), 0)
	screen._on_card_menu_chosen(DuelScreen.CARD_MENU_HAND_MANA)
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

func test_taste_of_paradise_opens_repeat_count_and_casts_paid_repetitions() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var spell := give_hand(0, "Taste of Paradise")
	add_mana(0, Mtg.ManaColor.G, 3)
	add_mana(0, Mtg.ManaColor.C, 5)
	var screen := _screen()
	screen._on_card_clicked(_local(screen, spell))
	assert_not_null(screen._x_dialog)
	if screen._x_dialog == null: return
	assert_eq(int(screen._x_spin.max_value), 2)
	screen._x_spin.value = 2
	screen._on_x_confirmed()
	await _pump()
	assert_eq(refusals, [])
	assert_eq(spell.zone, Mtg.Zone.STACK)
	assert_eq(g.stack.back().x_value, 2)
	resolve_stack()
	assert_eq(g.players[0].life, 29)

func test_fire_covenant_double_click_preserves_explicit_safe_life_choice() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	g.players[0].life = 17
	var spell := give_hand(0, "Fire Covenant")
	for color in [Mtg.ManaColor.B, Mtg.ManaColor.R, Mtg.ManaColor.C]: add_mana(0, color)
	var screen := _screen()
	screen._on_card_clicked(_local(screen, spell))
	assert_not_null(screen._x_dialog)
	if screen._x_dialog == null: return
	assert_eq(int(screen._x_spin.max_value), 17)
	assert_eq(int(screen._x_spin.value), 0)
	var asks_life := false
	for node in screen._x_dialog.body().get_children():
		if node is Label and node.text == "Life to pay (X):": asks_life = true
	assert_true(asks_life)
	screen._auto_cast(_local(screen, spell))
	await _pump()
	assert_not_null(screen._x_dialog)
	assert_true(referee.actions.draft.is_empty())
	assert_eq(g.players[0].life, 17)
	assert_eq(g.players[0].mana_pool.total(), 3)

func test_manual_mana_conversion_retries_a_waiting_cast_with_unchanged_total() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var agent := put_battlefield(0, "Agent of Stromgald")
	var ritual := give_hand(0, "Dark Ritual")
	add_mana(0, Mtg.ManaColor.R)
	var screen := _screen()
	screen._on_card_clicked(_local(screen, ritual))
	await _pump()
	assert_eq(screen.mode, DuelScreen.Mode.PAYING)
	screen._on_card_clicked(_local(screen, agent))
	await _pump()
	assert_eq(ritual.zone, Mtg.Zone.STACK, "red to black must retry although both pools total one")
	assert_eq(g.players[0].mana_pool.total(), 0)
	assert_eq(screen.mode, DuelScreen.Mode.NORMAL)

func test_taste_of_paradise_double_click_buys_available_repetitions() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var spell := give_hand(0, "Taste of Paradise")
	for i in 3: put_battlefield(0, "Forest")
	for i in 5: put_battlefield(0, "Mountain")
	var screen := _screen()
	screen._on_card_clicked(_local(screen, spell))
	screen._auto_cast(_local(screen, spell))
	await _pump()
	assert_eq(refusals, [])
	assert_eq(spell.zone, Mtg.Zone.STACK)
	assert_eq(g.stack.back().x_value, 2)
	assert_eq(g.players[0].mana_pool.total(), 0)
	resolve_stack()
	assert_eq(g.players[0].life, 29)

func test_fire_covenant_spends_only_explicit_life_and_damage_points() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	g.players[0].life = 17
	var spell := give_hand(0, "Fire Covenant")
	var victim := put_battlefield(1, "Hill Giant")
	for color in [Mtg.ManaColor.B, Mtg.ManaColor.R, Mtg.ManaColor.C]: add_mana(0, color)
	var screen := _screen()
	screen._on_card_clicked(_local(screen, spell))
	screen._x_spin.value = 3
	screen._on_x_confirmed()
	await _pump()
	assert_eq(g.players[0].life, 17, "aiming is not payment")
	for i in 3: screen._on_card_clicked(_local(screen, victim))
	await _pump()
	assert_eq(refusals, [])
	assert_eq(spell.zone, Mtg.Zone.STACK)
	assert_eq(g.stack.back().x_value, 3)
	assert_eq(g.players[0].life, 14)
	assert_eq(g.players[0].mana_pool.total(), 0)
	resolve_stack()
	assert_eq(victim.zone, Mtg.Zone.GRAVEYARD)
