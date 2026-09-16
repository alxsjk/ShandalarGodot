extends GutTest
## The shell's second pack row and the genuinely absent-pack UI contract.
## Availability is replaced only in this isolated test, never by moving ZIPs.

const IDS := ["pack-1", "pack-2", "pack-3", "pack-4", "pack-5"]
const DECK_PATH := "user://pack_absence_audit.deck"
var _available := {}
var _rejections: Array[Dictionary] = []
var _enabled: Array[String] = []
var _deck_names: Array[String] = []


func before_each() -> void:
	_available = CardPacks._available.duplicate(true)
	_rejections = CardPacks._rejections.duplicate(true)
	_enabled = Settings.enabled_card_packs()
	_deck_names = CardPacks._current_deck_names.duplicate()
	_publish(_available, [])


func after_each() -> void:
	CardPacks._available = _available
	CardPacks._rejections = _rejections
	Settings.set_value("enabled_card_packs", _enabled, false)
	CardPacks.set_current_deck_names(_deck_names)
	CardPacks._configure_registry()
	CardRegistry.ensure_loaded()
	ShellMusic.stop()
	if FileAccess.file_exists(DECK_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(DECK_PATH))


func _publish(available: Dictionary, enabled: Array) -> void:
	CardPacks._available = available.duplicate(true)
	CardPacks._rejections.clear()
	Settings.set_value("enabled_card_packs", enabled, false)
	CardPacks._configure_registry()
	CardRegistry.ensure_loaded()
	CardPacks.rescanned.emit()


func _screen(path: String) -> Control:
	var screen: Control = load(path).instantiate()
	add_child_autofree(screen)
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen.size = Vector2(1280, 800)
	for _frame in 3: await get_tree().process_frame
	return screen


func _words(root: Node) -> String:
	var out := ""
	for label in root.find_children("*", "Label", true, false):
		out += label.text + "\n"
	return out


func test_all_five_pack_badges_are_below_and_left_aligned_with_original_sets() -> void:
	var title := await _screen("res://game/main.tscn")
	var pool := title.find_child("CardPool", true, false) as Control
	var plaque := pool.get_child(0) as Control
	var first := title.find_child("Pack1", true, false) as Control
	var last := title.find_child("Pack5", true, false) as Control
	assert_not_null(first)
	assert_not_null(last)
	if first == null or last == null: return
	assert_gt(first.get_global_rect().position.y, plaque.get_global_rect().end.y,
		"pack badges belong below the original set strip")
	assert_almost_eq(first.get_global_rect().position.x, plaque.get_global_rect().position.x, 1.0)
	assert_almost_eq(last.get_global_rect().position.y, first.get_global_rect().position.y, 1.0)
	assert_lte(last.get_global_rect().end.x, 420.0, "the left corner stays out of the menu column")
	assert_almost_eq(plaque.size.y, plaque.get_combined_minimum_size().y, 1.0)


func test_future_badges_wrap_after_five_instead_of_widening_the_corner() -> void:
	var badges := CardPackBadges.new()
	add_child_autofree(badges)
	for _i in 3:
		var extra := Button.new()
		extra.custom_minimum_size = CardPackBadges.SIZE
		badges.add_child(extra)
	for _frame in 3: await get_tree().process_frame
	var first := badges.get_child(0) as Control
	var sixth := badges.get_child(5) as Control
	assert_gt(sixth.position.y, first.get_rect().end.y, "a sixth badge starts another line")
	assert_almost_eq(sixth.position.x, first.position.x, 1.0)
	assert_lte(badges.get_combined_minimum_size().x, 400.0)


func test_no_packs_keeps_core_pool_and_leaves_no_blank_badge_row() -> void:
	_publish({}, [])
	var title := await _screen("res://game/main.tscn")
	assert_eq(CardRegistry.size(), 897)
	assert_eq(CardRegistry.active_set_order(), CardRegistry.SET_ORDER)
	assert_string_contains(title.find_child("Version", true, false).text, "897 cards")
	for id in IDS: assert_null(title.find_child("Pack" + id.trim_prefix("pack-"), true, false))
	var pool := title.find_child("CardPool", true, false) as Control
	var plaque := pool.get_child(0) as Control
	assert_almost_eq(pool.size.y, plaque.get_combined_minimum_size().y, 1.0)
	assert_eq(ProxyCard.refusal_for(StarterDecks.WHITE_KNIGHTS), "")
	assert_eq(ProxyCard.refusal_for(StarterDecks.BLACK_RED_RAIDERS), "")


func test_stale_enabled_preferences_never_unlock_missing_cards_or_art() -> void:
	_publish({}, IDS)
	assert_eq(CardRegistry.size(), 897)
	for id in IDS:
		assert_false(CardPacks.is_enabled(id))
		assert_false(CardPacks.set_enabled(id, true))
		assert_false(CardPacks.status(id).available)
	for name in ["Chaos Orb", "Hymn to Tourach", "Necropotence", "Giant Oyster", "Force of Will"]:
		assert_false(CardRegistry.has_card(name), name)
	assert_eq(CardPacks.art_path("Force of Will", "all"), "")
	assert_eq(Array(Settings.enabled_card_packs()), IDS, "intent survives a temporarily missing ZIP")


func test_live_rescan_adds_and_removes_menu_badges_and_updates_count() -> void:
	_publish({}, IDS)
	var title := await _screen("res://game/main.tscn")
	_publish(_available, IDS)
	for _frame in 3: await get_tree().process_frame
	assert_not_null(title.find_child("Pack5", true, false))
	assert_string_contains(title.find_child("Version", true, false).text, "1,608 unique cards")
	_publish({}, IDS)
	for _frame in 3: await get_tree().process_frame
	assert_null(title.find_child("Pack5", true, false))
	assert_string_contains(title.find_child("Version", true, false).text, "897 cards")


func test_no_pack_options_are_readable_disabled_and_back_has_a_real_destination() -> void:
	_publish({}, [])
	var page := await _screen("res://game/card_packs_screen.tscn")
	for id in IDS:
		var number: String = id.trim_prefix("pack-")
		assert_true(page.find_child("EnablePack" + number, true, false).disabled)
		assert_true(page.find_child("DisablePack" + number, true, false).disabled)
		var words: String = page.find_child("Pack" + number + "Status", true, false).text
		assert_string_contains(words, "not found")
		assert_string_contains(words, CardPacks.file_name_for(id))
	var routes := RegEx.create_from_string('change_scene_to_file\\("([^"]+)"\\)').search_all(page.get_script().source_code)
	assert_eq(routes.size(), 1, "the Back route remains explicit")
	for route in routes: assert_true(ResourceLoader.exists(route.get_string(1)), route.get_string(1))


func test_no_pack_builder_keeps_original_cards_and_disables_unavailable_sources() -> void:
	_publish({}, IDS)
	var builder := await _screen("res://game/deck_builder/deck_builder_screen.tscn")
	assert_eq(builder._pool.size(), 897)
	assert_eq(builder.filter.apply(builder._pool).size(), 897)
	builder._open_extra_sets()
	await get_tree().process_frame
	assert_false(builder.find_child("ExtraOriginalOn", true, false).disabled)
	for id in IDS:
		var number: String = id.trim_prefix("pack-")
		assert_true(builder.find_child("ExtraPack" + number + "On", true, false).disabled)
		assert_true(builder.find_child("ExtraPack" + number + "Off", true, false).button_pressed)


func test_live_rescan_refreshes_builder_inventory_after_removing_enabled_packs() -> void:
	_publish(_available, IDS)
	var builder := await _screen("res://game/deck_builder/deck_builder_screen.tscn")
	assert_eq(builder._pool.size(), 1608)
	_publish({}, IDS)
	await get_tree().process_frame
	assert_eq(builder._pool.size(), 897)
	assert_eq(builder.filter.apply(builder._pool).size(), 897)


func test_missing_pack_deck_requires_consent_and_preserves_main_and_sideboard_names() -> void:
	_publish({}, [])
	var file := FileAccess.open(DECK_PATH, FileAccess.WRITE)
	file.store_string("# requires-pack: pack-5\nname: Missing Alliances\n1 Force of Will\nSB: 1 Storm Crow\n")
	file.close()
	var builder := await _screen("res://game/deck_builder/deck_builder_screen.tscn")
	assert_eq(builder.deck.add("Forest"), "")
	builder._load_deck(DECK_PATH)
	await get_tree().process_frame
	var notice: Control = builder._pack_requirement_notice
	assert_true(is_instance_valid(notice))
	if not is_instance_valid(notice): return
	assert_true(notice.find_child("EnablePack5", true, false).disabled)
	assert_string_contains(_words(notice), "Pack-5-Alliances.zip")
	assert_eq(builder.deck.count_of("Forest"), 1, "opening the warning cannot replace the current deck")
	notice.find_child("LoadAsProxies", true, false).pressed.emit()
	await get_tree().process_frame
	assert_eq(builder.deck.count_of("Force of Will"), 1)
	assert_eq(builder.deck.side_count_of("Storm Crow"), 1)
	assert_true(builder.deck.has_proxies())
	assert_ne(ProxyCard.refusal_for(["Force of Will"], ["Storm Crow"]), "")
	assert_string_contains(builder.deck.to_text(), "# requires-pack: pack-5")


func test_pack_removal_and_return_refresh_existing_deck_faces_legality_and_preview() -> void:
	_publish(_available, ["pack-5"])
	var builder := await _screen("res://game/deck_builder/deck_builder_screen.tscn")
	assert_eq(builder.deck.add("Force of Will"), "")
	assert_eq(builder.deck.add_side("Storm Crow"), "")
	builder.refresh()
	builder._show_in_showcase(CardRegistry.get_card("Force of Will"))
	_publish({}, ["pack-5"])
	await get_tree().process_frame
	assert_eq(builder.deck.count_of("Force of Will"), 1)
	assert_eq(builder.deck.side_count_of("Storm Crow"), 1)
	assert_true(ProxyCard.is_proxy_data(builder._deck_area._entries[0][0]))
	assert_true(ProxyCard.is_proxy_data(builder._sideboard_area._entries[0][0]))
	assert_string_contains(builder._legality_label.tooltip_text, "Force of Will")
	assert_true(builder._proxy_showcase.visible)
	_publish(_available, ["pack-5"])
	await get_tree().process_frame
	assert_false(ProxyCard.is_proxy_data(builder._deck_area._entries[0][0]))
	assert_false(ProxyCard.is_proxy_data(builder._sideboard_area._entries[0][0]))
	assert_false(builder._proxy_showcase.visible)
	assert_true(builder._showcase.visible)
