extends GutTest
## The Homelands doors use the same pack and independent filter contract.

func before_each() -> void:
	for id in CardPacks.available_ids(): CardPacks.set_enabled(id, false)
	CardPacks.set_enabled("pack-4", true)

func after_each() -> void:
	for id in CardPacks.available_ids(): CardPacks.set_enabled(id, false)
	CardPacks.set_current_deck_names([])
	ShellMusic.stop()
	Settings.clear_value(DeckBuilderScreen.EXTRAS_SETTING)   # remembered since 2026-09-17

func test_main_menu_has_compact_pack_four_information_and_live_counts() -> void:
	var title = load("res://game/main.tscn").instantiate()
	add_child_autofree(title)
	await get_tree().process_frame
	var button := title.find_child("Pack4", true, false) as Button
	assert_not_null(button)
	if button == null: return
	assert_eq(button.text, "4-HML")
	assert_lt(button.size.y, button.size.x)
	assert_string_contains(title.find_child("Version", true, false).text, "1,012 set entries · 1,012 unique cards")
	button.pressed.emit()
	await get_tree().process_frame
	assert_not_null(title._pack_notice)
	assert_false(title._pack_notice.find_child("Disable", true, false).disabled)

func test_extras_has_homelands_radio_medallions_and_live_filtering() -> void:
	var screen = load("res://game/deck_builder/deck_builder_screen.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.filter.original_cards_on = false
	screen.filter.completion_pack_on = false
	screen._open_extra_sets()
	await get_tree().process_frame
	var off := screen.find_child("ExtraPack4Off", true, false) as Button
	var on := screen.find_child("ExtraPack4On", true, false) as Button
	assert_not_null(off)
	assert_not_null(on)
	if off == null or on == null: return
	assert_eq(screen.filter.apply(screen._pool).size(), 115)
	off.pressed.emit()
	assert_eq(screen.filter.apply(screen._pool).size(), 0)
	on.pressed.emit()
	assert_eq(screen.filter.apply(screen._pool).size(), 115)
	assert_eq(on.custom_minimum_size, Vector2(48, 48))

func test_options_exposes_pack_four_and_deck_requirements_survive_disable() -> void:
	var page := CardPacksScreen.new()
	add_child_autofree(page)
	await get_tree().process_frame
	assert_not_null(page.find_child("Pack4Status", true, false))
	assert_not_null(page.find_child("EnablePack4", true, false))
	assert_not_null(page.find_child("DisablePack4", true, false))
	CardPacks.set_current_deck_names(["Merchant Scroll"])
	assert_string_contains(CardPacks.disable_warning("pack-4"), "Merchant Scroll")
	CardPacks.set_enabled("pack-4", false)
	assert_eq(CardPacks.packs_required_by(["Merchant Scroll"]), ["pack-4"])
	assert_eq(CardPacks.missing_requirements(["pack-4"]), ["pack-4"])

func test_homelands_gold_emblem_and_two_stone_faces_ship() -> void:
	for key in ["set_icon_hml", "filter_hml_on", "filter_hml_off"]:
		var texture := GameSkin.our_art(key)
		assert_not_null(texture, key)
		if texture != null: assert_eq(texture.get_size(), Vector2(48, 48))
