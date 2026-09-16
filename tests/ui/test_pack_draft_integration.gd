extends GutTest
## The merge must retain both draft provenance and pack requirements.

var saved_selection: Variant
var had_selection := false
var paths: Array[String] = []

func before_each() -> void:
	had_selection = Settings.has_value(DraftPoolConfig.SETTING)
	saved_selection = Settings.get_value(DraftPoolConfig.SETTING, [])
	Settings.clear_value(DraftPoolConfig.SETTING)
	for id in CardPacks.available_ids(): CardPacks.set_enabled(id, true)

func after_each() -> void:
	if had_selection: Settings.set_value(DraftPoolConfig.SETTING, saved_selection, false)
	else: Settings.clear_value(DraftPoolConfig.SETTING)
	for id in CardPacks.available_ids(): CardPacks.set_enabled(id, false)
	for path in paths:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	paths.clear()

func test_draft_selector_includes_expansions_and_preserves_explicit_choices() -> void:
	var selected := DraftPoolConfig.selected()
	assert_true(selected.has("Force of Will"))
	assert_true(selected.has("Ashen Ghoul"))
	var panel := DraftPoolDialog.new()
	add_child_autofree(panel)
	await get_tree().process_frame
	for code in ["fem", "ice", "hml", "all"]: assert_true(panel.groups.has(code), code)
	Settings.set_value(DraftPoolConfig.SETTING, ["Forest", "Force of Will"], false)
	CardPacks.set_enabled("pack-5", false)
	assert_eq(DraftPoolConfig.selected(), ["Forest"] as Array[String])
	CardPacks.set_enabled("pack-5", true)
	assert_eq(DraftPoolConfig.selected(), ["Force of Will", "Forest"] as Array[String])

func test_dealt_pack_cards_keep_recipe_requirements_copy_import_and_clear() -> void:
	var names: Array[String] = ["Force of Will", "Ashen Ghoul"]
	var options := {"boosters": 0, "starters": 0, "free_lands": 0, "extras": 2, "minutes": 20}
	var pool := DraftRecipe.deal(options, names, "a".repeat(64))
	assert_not_null(pool)
	if pool == null: return
	var store := DraftStore.new()
	assert_eq(store.prepare("user://test_pack_draft_integration", pool, options), "")
	paths.append_array([store.deck_path, store.pool_path, store.deck_path + ".pending", store.pool_path + ".pending"])
	var deck := DeckModel.new()
	deck.add("Force of Will")
	deck.sideboard["Ashen Ghoul"] = 1
	assert_eq(store.checkpoint(deck, "done"), "")
	var report: Array = []
	var loaded := DeckStore.load_deck(store.deck_path, report)
	assert_not_null(loaded)
	if loaded == null: return
	assert_eq(loaded.required_packs, ["pack-3", "pack-5"] as Array[String])
	assert_true(DraftAudit.reconstruct_text(loaded.to_text()).ok)
	for copy in [loaded.duplicate_model(), DeckStore.import_text(loaded.to_text(), "Draft", report), DeckStore.import_file(store.deck_path, report)]:
		assert_eq(copy.required_packs, loaded.required_packs)
		assert_eq(copy.draft_comments, loaded.draft_comments)
		assert_eq(copy.counts, loaded.counts)
		assert_eq(copy.sideboard, loaded.sideboard)
	CardPacks.set_enabled("pack-3", false)
	CardPacks.set_enabled("pack-5", false)
	var disabled := DeckStore.load_deck(store.deck_path, report)
	assert_eq(disabled.required_packs, loaded.required_packs)
	assert_true(disabled.proxy_names().has("Force of Will"))
	var embedded := DraftRecipe.from_text(disabled.to_text())
	assert_true(embedded.ok)
	assert_true(DraftRecipe.reconstruct(embedded.recipe).ok, "frozen recipe replay does not require active rules")
	assert_false(DraftAudit.reconstruct_text(disabled.to_text()).ok, "the playable-pool audit still refuses disabled identities")
	loaded.clear()
	assert_eq(loaded.draft_comments, "")
	assert_true(loaded.required_packs.is_empty())

func test_required_pack_comments_do_not_break_blank_or_explicit_sideboards() -> void:
	for text in ["# requires-pack: pack-5\n4 Force of Will\n\n# requires-pack: pack-3\n2 Ashen Ghoul\n",
		"# requires-pack: pack-5\n4 Force of Will\n\n# requires-pack: pack-3\nSB: 2 Ashen Ghoul\n"]:
		var report: Array = []
		var model := DeckStore.import_text(text, "Pack deck", report)
		assert_not_null(model)
		if model == null: continue
		assert_eq(model.total(), 4)
		assert_eq(model.side_total(), 2)
		assert_eq(model.required_packs, ["pack-5", "pack-3"] as Array[String])

func test_snow_basics_use_the_common_sheet_without_changing_frozen_recipe_land_slots() -> void:
	var sheets := SealedPool.sheets(DraftPoolConfig.library(["Forest", "Snow-Covered Forest"]))
	assert_eq(sheets.land, ["Forest"])
	assert_eq(sheets.common, ["Snow-Covered Forest"])
	assert_eq(SealedPool.slot_of("Snow-Covered Forest"), "common")
	assert_eq(DeckStats.rarity_of("Force of Will"), "uncommon")
	assert_eq(DeckStats.rarity_of("Ashen Ghoul"), "uncommon")
	var pool := DraftRecipe.deal(DraftPoolConfig.defaults(), DraftPoolConfig.selected(), "b".repeat(64))
	assert_not_null(pool, "all enabled packs must support a valid ordinary draft")
	if pool != null: assert_true(DraftRecipe.reconstruct(pool.draft_recipe).ok)

func test_saving_visible_draft_choices_preserves_temporarily_disabled_pack_choices() -> void:
	Settings.set_value(DraftPoolConfig.SETTING, ["Forest", "Force of Will"], false)
	CardPacks.set_enabled("pack-5", false)
	var panel := DraftPoolDialog.new()
	add_child_autofree(panel)
	panel.choose(["Island"])
	panel._save()
	assert_eq(DraftPoolConfig.selected(), ["Island"] as Array[String])
	CardPacks.set_enabled("pack-5", true)
	assert_eq(DraftPoolConfig.selected(), ["Force of Will", "Island"] as Array[String])
	var enabled_panel := DraftPoolDialog.new()
	add_child_autofree(enabled_panel)
	enabled_panel.choose(["Island"])
	enabled_panel._save()
	assert_eq(DraftPoolConfig.selected(), ["Island"] as Array[String], "visible unchecked cards are deliberately removed")

func test_deck_requirement_popup_explains_a_live_catalogue_lock() -> void:
	CardPacks.set_enabled("pack-5", false)
	var server := SgLocalServer.new()
	add_child_autofree(server)
	assert_eq(server.start_local(0), OK)
	var builder = load("res://game/deck_builder/deck_builder_screen.tscn").instantiate()
	add_child_autofree(builder)
	var deck := DeckModel.new()
	deck.add_proxy("Force of Will")
	deck.required_packs.assign(["pack-5"])
	builder._offer_required_pack("user://unused-test.deck", deck, [], "pack-5")
	var notice: Control = builder._pack_requirement_notice
	var enable := notice.find_child("EnablePack5", true, false) as Button
	assert_not_null(enable)
	if enable != null: assert_true(enable.disabled)
	var text := ""
	for label in notice.find_children("*", "Label", true, false): text += label.text
	assert_string_contains(text, "stop hosting")
	server.stop()
