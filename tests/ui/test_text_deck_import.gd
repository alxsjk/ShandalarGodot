extends GutTest
## Plain-text imports: blank-line sideboards, existing formats and safe round trips.

const FOLDER := "user://test_text_deck_import"
const NECRO := """4 Black Knight
4 Dark Ritual
4 Drain Life
4 Hymn to Tourach
4 Hypnotic Specter
2 Icy Manipulator
1 Ihsan's Shade
1 Ivory Tower
4 Necropotence
3 Nevinyrral's Disk
4 Order of the Ebon Hand
2 Sengir Vampire
4 Strip Mine
18 Swamp
1 Zuran Orb

3 Dystopia
1 Feldon's Cane
1 Fountain of Youth
3 Gloom
1 Nevinyrral's Disk
3 Serrated Arrows
3 Terror
"""
var files: Array[String] = []


func before_each() -> void:
	CardRegistry.ensure_loaded()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FOLDER))


func after_each() -> void:
	for path in files:
		DirAccess.remove_absolute(path)
	files.clear()


func _write(filename: String, text: String) -> String:
	var path := FOLDER.path_join(filename)
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()
	files.append(path)
	return path


func test_necro_txt_imports_sixty_main_and_fifteen_sideboard() -> void:
	var path := _write("The NecroDeck.txt", NECRO.replace("\n", "\r\n"))
	var report: Array = []
	var model := DeckStore.import_file(path, report)
	assert_not_null(model)
	if model == null: return
	assert_eq(model.total(), 60)
	assert_eq(model.side_total(), 15)
	assert_eq(model.deck_name, "The NecroDeck")
	assert_eq(model.count_of("Nevinyrral's Disk"), 3)
	assert_eq(model.side_count_of("Nevinyrral's Disk"), 1)
	assert_eq(model.count_of("Necropotence"), 4, "Unavailable cards are preserved")
	assert_eq(model.side_count_of("Dystopia"), 3)
	assert_false(report.is_empty(), "Unavailable cards still produce a warning")


func test_pasting_the_same_plain_list_keeps_the_same_two_piles() -> void:
	var report: Array = []
	var model := DeckStore.import_text(NECRO, "The NecroDeck", report)
	assert_not_null(model)
	if model == null: return
	assert_eq(model.total(), 60)
	assert_eq(model.side_total(), 15)


func test_txt_handles_bom_crlf_headers_and_leading_whitespace() -> void:
	var path := _write("windows.TXT", "\ufeff\r\n \t\r\n# A list\r\nname: Windows\r\n\r\n"
		+ "4x Lightning Bolt\r\n20 Mountain\r\n \t\r\n# Sideboard\r\n2 Shatter\r\n\r\n")
	var list := DeckList.load_file(path)
	assert_eq(list.errors, [] as Array[String])
	assert_eq(list.deck_name, "Windows")
	assert_eq(list.cards.size(), 24)
	assert_eq(list.sideboard, ["Shatter", "Shatter"] as Array[String])


func test_plain_list_without_separator_has_no_sideboard() -> void:
	var path := _write("main.txt", "\n// NAME: Main only\n\n4 Lightning Bolt\n20 Mountain\n")
	var list := DeckList.load_file(path)
	assert_eq(list.errors, [] as Array[String])
	assert_eq(list.cards.size(), 24)
	assert_true(list.sideboard.is_empty())


func test_repeated_blanks_never_switch_back_to_main_deck() -> void:
	var path := _write("blanks.txt", "4 Mountain\n\n\n1 Shatter\n\n# Another\n\n2 Forest\n\n")
	var list := DeckList.load_file(path)
	assert_eq(list.errors, [] as Array[String])
	assert_eq(list.cards.size(), 4)
	assert_eq(list.sideboard, ["Shatter", "Forest", "Forest"] as Array[String])


func test_comments_alone_do_not_start_sideboard() -> void:
	var path := _write("comments.txt", "4 Mountain\n# Creatures\n// Group\n2 Grizzly Bears\n")
	var list := DeckList.load_file(path)
	assert_eq(list.errors, [] as Array[String])
	assert_eq(list.cards.size(), 6)
	assert_true(list.sideboard.is_empty())


func test_explicit_sideboard_markers_override_blank_line_inference() -> void:
	var text := "4 Mountain\n\n2 Grizzly Bears\n\n sb: 1 Shatter\n1 Forest\n"
	var path := _write("explicit.txt", text)
	var list := DeckList.load_file(path)
	assert_eq(list.errors, [] as Array[String])
	assert_eq(list.cards.size(), 7, "Only marked lines go to sideboard")
	assert_eq(list.sideboard, ["Shatter"] as Array[String])
	var report: Array = []
	var model := DeckStore.import_text(text, "Explicit", report)
	assert_not_null(model)
	if model == null: return
	assert_eq(model.total(), 7)
	assert_eq(model.side_total(), 1)


func test_native_and_dec_blank_line_meaning_is_unchanged() -> void:
	for extension in ["deck", "dec"]:
		var path := _write("grouped." + extension, "4 Mountain\n\n2 Grizzly Bears\n")
		var list := DeckList.load_file(path)
		assert_eq(list.errors, [] as Array[String])
		assert_eq(list.cards.size(), 6, extension)
		assert_true(list.sideboard.is_empty(), extension)


func test_strict_loading_still_rejects_unknown_sideboard_cards() -> void:
	var path := _write("proxy.txt", "4 Mountain\n\n1 Zzz Notional Card\n2 Shatter\n")
	var list := DeckList.load_file(path)
	assert_eq(list.errors.size(), 1)
	assert_string_contains(list.errors[0], "Zzz Notional Card")
	assert_eq(list.cards.size(), 4)
	assert_eq(list.sideboard, ["Shatter", "Shatter"] as Array[String])
	var lenient := DeckList.load_file(path, false)
	assert_eq(lenient.errors, [] as Array[String])
	assert_eq(lenient.sideboard.size(), 3)
	assert_eq(lenient.proxies, ["Zzz Notional Card"] as Array[String])


func test_bad_sideboard_line_refuses_import_instead_of_dropping_cards() -> void:
	var path := _write("bad.txt", "4 Mountain\n\nzero Shatter\n")
	var report: Array = []
	assert_null(DeckStore.import_file(path, report))
	assert_false(report.is_empty())


func test_plain_import_round_trips_through_native_save_format() -> void:
	var report: Array = []
	var model := DeckStore.import_text(NECRO, "The NecroDeck", report)
	assert_not_null(model)
	if model == null: return
	var path := _write("saved.deck", model.to_text())
	var saved := DeckStore.import_file(path, [])
	assert_not_null(saved)
	if saved == null: return
	assert_eq(saved.total(), 60)
	assert_eq(saved.side_total(), 15)
	assert_eq(saved.counts, model.counts)
	assert_eq(saved.sideboard, model.sideboard)


func test_txt_is_offered_for_import_but_not_automatically_indexed() -> void:
	var path := _write("listed.TXT", "4 Mountain\n\n2 Shatter\n")
	assert_false(DeckStore.deck_paths_in(FOLDER).has(path), "Do not index ratings.txt or notes as saved decks")
	assert_true("\n".join(DeckStore.IMPORT_FILTERS).contains("*.txt"))
