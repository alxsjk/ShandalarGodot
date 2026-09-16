extends GutTest
## The Alliances doors use the same pack and independent filter contract.

func before_each() -> void:
	for id in CardPacks.available_ids(): CardPacks.set_enabled(id, false)
	CardPacks.set_enabled("pack-5", true)

func after_each() -> void:
	for id in CardPacks.available_ids(): CardPacks.set_enabled(id, false)
	CardPacks.set_current_deck_names([])
	ShellMusic.stop()

func test_main_menu_has_compact_pack_five_information_and_live_counts() -> void:
	var title = load("res://game/main.tscn").instantiate()
	add_child_autofree(title)
	await get_tree().process_frame
	var button := title.find_child("Pack5", true, false) as Button
	assert_not_null(button)
	if button == null: return
	assert_eq(button.text, "5-ALL")
	assert_lt(button.size.y, button.size.x)
	assert_string_contains(title.find_child("Version", true, false).text, "1,041 set entries · 1,041 unique cards")
	button.pressed.emit()
	await get_tree().process_frame
	assert_not_null(title._pack_notice)
	assert_false(title._pack_notice.find_child("Disable", true, false).disabled)

func test_extras_has_alliances_radio_medallions_and_live_filtering() -> void:
	var screen = load("res://game/deck_builder/deck_builder_screen.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.filter.original_cards_on = false
	screen.filter.completion_pack_on = false
	screen._open_extra_sets()
	await get_tree().process_frame
	var off := screen.find_child("ExtraPack5Off", true, false) as Button
	var on := screen.find_child("ExtraPack5On", true, false) as Button
	assert_not_null(off)
	assert_not_null(on)
	if off == null or on == null: return
	assert_eq(screen.filter.apply(screen._pool).size(), 144)
	off.pressed.emit()
	assert_eq(screen.filter.apply(screen._pool).size(), 0)
	on.pressed.emit()
	assert_eq(screen.filter.apply(screen._pool).size(), 144)
	assert_eq(on.custom_minimum_size, Vector2(48, 48))

func test_options_exposes_pack_five_and_deck_requirements_survive_disable() -> void:
	var page := CardPacksScreen.new()
	add_child_autofree(page)
	await get_tree().process_frame
	assert_not_null(page.find_child("Pack5Status", true, false))
	assert_not_null(page.find_child("EnablePack5", true, false))
	assert_not_null(page.find_child("DisablePack5", true, false))
	CardPacks.set_current_deck_names(["Arcane Denial"])
	assert_string_contains(CardPacks.disable_warning("pack-5"), "Arcane Denial")
	CardPacks.set_enabled("pack-5", false)
	assert_eq(CardPacks.packs_required_by(["Arcane Denial"]), ["pack-5"])
	assert_eq(CardPacks.missing_requirements(["pack-5"]), ["pack-5"])

func test_alliances_gold_emblem_and_two_stone_faces_ship() -> void:
	for key in ["set_icon_all", "filter_all_on", "filter_all_off"]:
		var texture := GameSkin.our_art(key)
		assert_not_null(texture, key)
		if texture != null: assert_eq(texture.get_size(), Vector2(48, 48))

func test_local_cast_retries_after_red_to_black_mana_conversion() -> void:
	var screen: DuelScreen = load("res://game/duel/duel_screen.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.set_process(false)
	screen._toss_active = false
	var g := screen.game
	g.active_player = 0
	g.priority_player = 0
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.MAIN1)
	g.awaiting_attackers = false
	g.awaiting_blockers = false
	g.players[0].hand.clear()
	g.players[0].battlefield.clear()
	g.players[0].mana_pool.clear()
	var agent := CardInstance.new(CardRegistry.get_card("Agent of Stromgald"), 95001, 0)
	var ritual := CardInstance.new(CardRegistry.get_card("Dark Ritual"), 95002, 0)
	for card in [agent, ritual]: g._instances[card.id] = card
	g._put_on_battlefield(agent, 0)
	ritual.zone = Mtg.Zone.HAND
	g.players[0].hand.append(ritual)
	g.players[0].mana_pool.add(Mtg.ManaColor.R)
	screen.mode = DuelScreen.Mode.NORMAL
	screen._click_hand_card(ritual)
	assert_eq(screen.mode, DuelScreen.Mode.PAYING)
	screen._tap_for_payment(agent)
	assert_eq(ritual.zone, Mtg.Zone.STACK)
	assert_eq(g.players[0].mana_pool.total(), 0)
	assert_eq(screen.mode, DuelScreen.Mode.NORMAL)
