extends GutTest
## THE OPTIONS SCREEN'S SLIDERS write the settings file ONCE per drag, not
## once per pixel. `HSlider.value_changed` fires for every step the handle
## crosses, and until 2026-09-02 each one rewrote `user://settings.cfg` —
## a volume drag was sixty file writes a second. Now a tick applies the
## value in memory (`Settings.set_value(key, value, false)`), and the file
## is written when the drag ends, when focus leaves the slider, or when
## the screen does.


var screen: Control
var _saved := {}
const KEYS := ["ai_pace", "sfx_volume_db", "music_volume_db"]


func before_each() -> void:
	# The player's real file must not keep anything a test set.
	for key in KEYS:
		_saved[key] = Settings.get_value(key, null) if Settings.has_value(key) else null
	screen = load("res://game/options_screen.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame


func after_each() -> void:
	for key in KEYS:
		if _saved[key] == null:
			Settings.clear_value(key)
		else:
			Settings.set_value(key, _saved[key])


func _sliders() -> Array[HSlider]:
	var out: Array[HSlider] = []
	for node in _walk(screen):
		if node is HSlider:
			out.append(node)
	return out


func _walk(node: Node) -> Array:
	var out := [node]
	for child in node.get_children():
		out.append_array(_walk(child))
	return out


## The pace slider is the one whose range is 0.1..1.5.
func _pace_slider() -> HSlider:
	for slider in _sliders():
		if is_equal_approx(slider.max_value, 1.5):
			return slider
	return null


## What the file on disk says, read fresh — not what Settings remembers.
static func _on_disk(key: String) -> Variant:
	var file := ConfigFile.new()
	file.load(Settings.PATH)
	if not file.has_section_key("options", key):
		return null
	return file.get_value("options", key)


func test_the_screen_has_its_three_sliders() -> void:
	assert_eq(_sliders().size(), 3, "pace, sfx, music")
	assert_not_null(_pace_slider())


func test_a_tick_of_the_drag_applies_but_does_not_write() -> void:
	var pace := _pace_slider()
	Settings.flush()
	pace.value = 0.75                    # emits value_changed
	assert_almost_eq(Settings.ai_pace(), 0.75, 0.001, "applied in memory")
	assert_true(Settings.is_dirty(), "and waiting to be written")
	assert_ne(_on_disk("ai_pace"), 0.75, "the file was not touched yet")


func test_letting_go_of_the_handle_writes_once() -> void:
	var pace := _pace_slider()
	pace.value = 0.6
	pace.drag_ended.emit(true)
	assert_false(Settings.is_dirty())
	assert_almost_eq(float(_on_disk("ai_pace")), 0.6, 0.001, "on disk now")


func test_leaving_the_slider_by_keyboard_writes_too() -> void:
	var pace := _pace_slider()
	pace.value = 0.45                    # arrow keys: no drag to end
	pace.focus_exited.emit()
	assert_false(Settings.is_dirty())
	assert_almost_eq(float(_on_disk("ai_pace")), 0.45, 0.001)


func test_leaving_the_screen_writes_whatever_is_waiting() -> void:
	var pace := _pace_slider()
	pace.value = 0.9
	assert_true(Settings.is_dirty())
	screen.get_parent().remove_child(screen)   # _exit_tree
	screen.queue_free()
	assert_false(Settings.is_dirty())
	assert_almost_eq(float(_on_disk("ai_pace")), 0.9, 0.001)


func test_a_volume_tick_still_reaches_the_bus_at_once() -> void:
	# The reason the value is applied per tick at all: a duel behind the
	# screen mixes on the bus while the handle moves.
	for slider in _sliders():
		if slider == _pace_slider():
			continue
		slider.value = -21.0
	assert_almost_eq(GameAudio.bus_volume_db(GameAudio.SFX_BUS), -21.0, 0.01)
	assert_almost_eq(GameAudio.bus_volume_db(GameAudio.MUSIC_BUS), -21.0, 0.01)
	assert_true(Settings.is_dirty(), "written later, not now")


func test_a_persisting_set_carries_the_dirty_keys_with_it() -> void:
	# Settings.set_value with persist saves the WHOLE file, so a slider
	# tick followed by any ordinary write loses nothing.
	_pace_slider().value = 0.55
	Settings.set_value("sfx_volume_db", -9.0)
	assert_false(Settings.is_dirty())
	assert_almost_eq(float(_on_disk("ai_pace")), 0.55, 0.001)


func test_audit_failed_save_stays_dirty_and_flush_retries() -> void:
	# 2026-09-13, before the fix: SETTINGS dirty=false counted_writes=1
	# with a directory blocking settings.cfg. Restore the file before any
	# assertions, including on fixture failure; the suite profile is shared.
	Settings.flush()
	var path := ProjectSettings.globalize_path(Settings.PATH)
	var backup := path + ".audit-%d" % Time.get_ticks_usec()
	var existed := FileAccess.file_exists(path)
	if existed and DirAccess.rename_absolute(path, backup) != OK:
		fail_test("could not protect the test profile's settings")
		return
	if DirAccess.make_dir_absolute(path) != OK:
		if existed:
			DirAccess.rename_absolute(backup, path)
		fail_test("could not create the blocked-save fixture")
		return
	var before := Settings.write_count
	Settings.set_value("ai_pace", 0.65)
	var dirty_after_failure := Settings.is_dirty()
	var writes_after_failure := Settings.write_count - before
	DirAccess.remove_absolute(path)
	if existed:
		DirAccess.rename_absolute(backup, path)
	Settings.flush()
	assert_true(dirty_after_failure, "failed save must remain pending")
	assert_eq(writes_after_failure, 0, "failed writes are not counted as saved")
	assert_false(Settings.is_dirty(), "flush retries after the obstruction is gone")
	assert_eq(Settings.write_count - before, 1, "one successful retry")
	assert_eq(_on_disk("ai_pace"), 0.65)
