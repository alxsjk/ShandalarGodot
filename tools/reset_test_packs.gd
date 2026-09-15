extends SceneTree
## A canceled pack test can skip after_each. Reset only the isolated
## test profile's enabled-pack setting before the next GUT process boots.
func _init() -> void: call_deferred("_reset")
func _reset() -> void:
	# runtime.sh exports XDG_DATA_HOME even when the caller used the default
	# (SHANDALAR_TEST_DATA_HOME itself need not have been exported).
	var test_root := OS.get_environment("XDG_DATA_HOME").simplify_path().trim_suffix("/")
	var isolated_linux := OS.get_name() == "Linux" and test_root != "" \
		and OS.get_user_data_dir().begins_with(test_root + "/")
	if not OS.has_feature("shandalar_test") and not isolated_linux:
		printerr("Refusing to reset packs outside the isolated test profile")
		quit(2)
		return
	Settings.set_value("enabled_card_packs", [])
	quit(0)
