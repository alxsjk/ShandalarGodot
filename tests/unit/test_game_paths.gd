extends GutTest
## `[QoL]` THE PLAYER'S PLACES — [GamePaths]: six keys in
## `user://settings.cfg` that move the skin zip, the skin folder, the
## card folder, the portraits folder and the music folder, none of them
## ever written by the game as a default. The owner, 2026-09-08: *"the
## default folder location should be shown in settings but can also be
## changed in cfg"*.

## Remembered and put back — never written back as a default.
const KEYS: Array[String] = [GamePaths.KEY_SKIN_ZIP, GamePaths.KEY_USE_SKIN_FOLDER,
	GamePaths.KEY_SKIN_FOLDER, GamePaths.KEY_CARDPACKS, GamePaths.KEY_PORTRAITS,
	GamePaths.KEY_MUSIC]

var _saved: Dictionary = {}


func before_each() -> void:
	_saved = {}
	for key in KEYS:
		_saved[key] = Settings.get_value(key, null) if Settings.has_value(key) else null
		Settings.clear_value(key)


func after_each() -> void:
	for key in KEYS:
		if _saved[key] == null:
			Settings.clear_value(key)
		else:
			Settings.set_value(key, _saved[key])


func test_the_built_in_places_when_no_key_is_written() -> void:
	assert_eq(GamePaths.skin_zip(), "", "the game's own pick")
	assert_false(GamePaths.use_skin_folder())
	assert_eq(GamePaths.skin_folder(), "user://original_skin")
	assert_eq(GamePaths.cardpacks_folder(), "user://cardpacks")
	assert_eq(GamePaths.portraits_folder(), "user://portraits")
	assert_eq(GamePaths.music_folder(), "user://music")
	for key in KEYS:
		assert_false(Settings.has_value(key), "reading %s leaves no trace" % key)


func test_a_key_moves_its_place() -> void:
	Settings.set_value(GamePaths.KEY_SKIN_FOLDER, "/srv/mtg/skin")
	Settings.set_value(GamePaths.KEY_CARDPACKS, "/srv/mtg/packs/")
	Settings.set_value(GamePaths.KEY_PORTRAITS, "  user://faces  ")
	Settings.set_value(GamePaths.KEY_MUSIC, "~/Music/shandalar")
	Settings.set_value(GamePaths.KEY_SKIN_ZIP, "~/skins/mine.zip")
	assert_eq(GamePaths.skin_folder(), "/srv/mtg/skin")
	assert_eq(GamePaths.cardpacks_folder(), "/srv/mtg/packs", "a trailing slash dropped")
	assert_eq(GamePaths.portraits_folder(), "user://faces", "edges trimmed")
	var home := GamePaths._home_dir()
	assert_eq(GamePaths.music_folder(), home + "/Music/shandalar", "~ is the home folder")
	assert_eq(GamePaths.skin_zip(), home + "/skins/mine.zip")


func test_an_empty_or_wrong_typed_key_is_the_built_in_place() -> void:
	Settings.set_value(GamePaths.KEY_MUSIC, "")
	assert_eq(GamePaths.music_folder(), "user://music")
	Settings.set_value(GamePaths.KEY_MUSIC, "   ")
	assert_eq(GamePaths.music_folder(), "user://music")
	Settings.set_value(GamePaths.KEY_PORTRAITS, 42)
	assert_eq(GamePaths.portraits_folder(), "user://portraits", "a number is not a path")
	Settings.set_value(GamePaths.KEY_SKIN_ZIP, false)
	assert_eq(GamePaths.skin_zip(), "")
	Settings.set_value(GamePaths.KEY_CARDPACKS, "/")
	assert_eq(GamePaths.cardpacks_folder(), "/", "the root keeps its one slash")


func test_the_folder_switch_is_a_key_written_only_when_moved() -> void:
	GamePaths.set_use_skin_folder(true)
	assert_true(GamePaths.use_skin_folder())
	assert_true(Settings.has_value(GamePaths.KEY_USE_SKIN_FOLDER))
	GamePaths.set_use_skin_folder(false)
	assert_false(GamePaths.use_skin_folder())
	Settings.set_value(GamePaths.KEY_USE_SKIN_FOLDER, "yes")
	assert_true(GamePaths.use_skin_folder(), "a hand-typed non-empty string reads as on")


func test_expand_touches_only_a_leading_tilde() -> void:
	var home := GamePaths._home_dir()
	assert_eq(GamePaths.expand("~"), home)
	assert_eq(GamePaths.expand("~/x"), home + "/x")
	assert_eq(GamePaths.expand("/a/~/b"), "/a/~/b")
	assert_eq(GamePaths.expand("~user/x"), "~user/x", "somebody else's home is not guessed")
	assert_eq(GamePaths.expand("user://x"), "user://x")


func test_audit_home_expansion_without_unix_home() -> void:
	# Emulate the environment of a Windows desktop launch, without
	# touching the filesystem or yielding while process-wide vars differ.
	var original_env := {}
	for key in ["HOME", "USERPROFILE"]:
		original_env[key] = OS.get_environment(key) if OS.has_environment(key) else null
	OS.unset_environment("HOME")
	OS.set_environment("USERPROFILE", "C:\\Users\\Deck Tester")
	var expanded := GamePaths.expand("~/Music")
	var bare := GamePaths.expand("~")
	OS.unset_environment("USERPROFILE")
	var unknown := GamePaths.expand("~/Music")
	var unknown_bare := GamePaths.expand("~")
	for key in original_env:
		if original_env[key] == null:
			OS.unset_environment(key)
		else:
			OS.set_environment(key, original_env[key])
	assert_eq(expanded, "C:/Users/Deck Tester/Music")
	assert_eq(bare, "C:/Users/Deck Tester")
	assert_eq(unknown, "~/Music", "unknown home must not become the filesystem root")
	assert_eq(unknown_bare, "~", "unknown home must not disappear")


func test_a_place_is_shown_as_a_path_a_human_can_open() -> void:
	assert_eq(GamePaths.shown(""), "")
	assert_eq(GamePaths.shown("/srv/x"), "/srv/x")
	var home := GamePaths._home_dir()
	assert_eq(GamePaths.shown(home + "/Music"), "~/Music", "the home folder as ~")
	assert_eq(GamePaths.shown(home), "~")
	assert_eq(GamePaths.shown(home + "sib/x"), home + "sib/x", "a sibling that shares the prefix is not home")
	var music := ProjectSettings.globalize_path("user://music")
	if music.begins_with(home + "/"):
		assert_eq(GamePaths.shown("user://music"), "~" + music.substr(home.length()))
	else:
		assert_eq(GamePaths.shown("user://music"), music)
	assert_true(GamePaths.settings_file().ends_with("/settings.cfg"))
	assert_eq(GamePaths.settings_file(), GamePaths.shown(Settings.PATH))


func test_only_the_games_own_home_is_its_to_empty() -> void:
	assert_true(GamePaths.is_own("user://cardpacks"))
	assert_true(GamePaths.is_own("user://skins/mine.zip"))
	assert_false(GamePaths.is_own("/home/somebody/cardpacks"))
	assert_false(GamePaths.is_own("res://assets/cardart"))
	assert_false(GamePaths.is_own(ProjectSettings.globalize_path("user://cardpacks")),
		"a globalised path is not recognised — the keys are compared as written")


func test_the_place_keys_are_the_ones_the_options_note_names() -> void:
	assert_eq(GamePaths.PLACE_KEYS, ["skin_zip", "skin_folder", "cardpacks_folder",
		"portraits_folder", "music_folder"] as Array[String])
	assert_false(GamePaths.KEY_USE_SKIN_FOLDER in GamePaths.PLACE_KEYS,
		"the switch has its own row; it is not a place")


func test_a_user_prefix_does_not_make_a_parent_folder_ours_to_delete() -> void:
	assert_false(GamePaths.is_own("user://../other-game/cardpacks"))
	assert_false(GamePaths.is_own("user://cardpacks/../../other-game"))
	assert_false(GamePaths.is_own("user://..\\other-game\\cardpacks"))
	assert_true(GamePaths.is_own("user://cardpacks/../skins"),
		"a normalised path that stays inside the profile is still ours")


func test_a_linked_folder_is_the_players_to_manage() -> void:
	var root := "user://game_paths_link_%d" % Time.get_ticks_usec()
	var target := root.path_join("target")
	var link := root.path_join("link")
	assert_eq(DirAccess.make_dir_recursive_absolute(target), OK)
	var dir := DirAccess.open(root)
	assert_eq(dir.create_link(ProjectSettings.globalize_path(target), "link"), OK)
	assert_false(GamePaths.is_own(link))
	assert_false(GamePaths.is_own(link.path_join("pack.zip")))
	assert_false(GamePaths.is_own(link.path_join("../target")),
		"normalisation must not hide a traversed symlink")
	assert_true(GamePaths.is_own(target))
	assert_eq(DirAccess.remove_absolute(link), OK)
	assert_eq(DirAccess.remove_absolute(target), OK)
	assert_eq(DirAccess.remove_absolute(root), OK)


func test_deck_delete_refuses_a_sibling_whose_name_starts_with_decks() -> void:
	var path := "user://decks_guard_probe_%d.deck" % Time.get_ticks_usec()
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("this is a test fixture outside the decks directory")
	file.close()
	assert_false(DeckStore.is_user_deck(path))
	assert_ne(DeckStore.delete_deck(path), "")
	assert_true(FileAccess.file_exists(path), "delete must leave the sibling intact")
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func test_deck_delete_classification_rejects_parent_escapes() -> void:
	assert_false(DeckStore.is_user_deck("user://decks/../music/keep.deck"))
	assert_false(DeckStore.is_user_deck("user://decks/../../other-game/keep.deck"))
	assert_false(DeckStore.is_user_deck("user://decks"))
	assert_true(DeckStore.is_user_deck("user://decks/my_deck.deck"))


func test_portable_files_live_beside_a_macos_bundle() -> void:
	assert_eq(GamePaths.executable_dir("/Games/Shandalar.app/Contents/MacOS/Shandalar", true), "/Games")
	assert_eq(GamePaths.executable_dir("/Games/My Game.app/Contents/MacOS/Shandalar", true), "/Games")
	assert_eq(GamePaths.executable_dir("/Games/Shandalar.x86_64", false), "/Games")
	assert_eq(GamePaths.executable_dir("/Games/Shandalar", true), "/Games")
	assert_eq(GamePaths.executable_dir("/Games/Other/Contents/MacOS/game", true),
		"/Games/Other/Contents/MacOS", "only a real .app path is unwrapped")
