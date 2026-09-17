extends GutTest
## The Verify button keeps keyboard focus under the verifier's overlay:
## Enter pressed again must not stack a second window on the first.


var saved: Dictionary = {}


func before_each() -> void:
	CardRegistry.ensure_loaded()
	for key in [DraftPoolConfig.SETTING, DraftPoolConfig.OPTIONS, GamePaths.KEY_DRAFTS]:
		saved[key] = Settings.get_value(key, 0) if Settings.has_value(key) else null
		Settings.clear_value(key)


func after_each() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	for key in saved:
		if saved[key] == null: Settings.clear_value(key)
		else: Settings.set_value(key, saved[key], false)


func _verifiers(setup: DraftSetup) -> Array:
	var out: Array = []
	for child in setup.get_children():
		if child is DraftVerifier and not child.is_queued_for_deletion(): out.append(child)
	return out


func test_pressing_verify_twice_opens_one_verifier() -> void:
	var setup := DraftSetup.new()
	add_child_autofree(setup)
	var button: Button = setup.find_child("VerifyDraftDeck", true, false)
	button.pressed.emit()
	button.pressed.emit()
	assert_eq(_verifiers(setup).size(), 1, "one verifier, however often the button fires")


func test_verify_reopens_after_the_verifier_went_back() -> void:
	var setup := DraftSetup.new()
	add_child_autofree(setup)
	var button: Button = setup.find_child("VerifyDraftDeck", true, false)
	button.pressed.emit()
	var first: DraftVerifier = _verifiers(setup)[0]
	first.queue_free()
	await get_tree().process_frame
	button.pressed.emit()
	var open := _verifiers(setup)
	assert_eq(open.size(), 1, "a fresh verifier after the first closed")
	assert_ne(open[0], first)


func test_the_verifier_takes_keyboard_focus_from_the_setup() -> void:
	var setup := DraftSetup.new()
	add_child_autofree(setup)
	var button: Button = setup.find_child("VerifyDraftDeck", true, false)
	button.grab_focus()
	button.pressed.emit()
	var owner: Control = get_viewport().gui_get_focus_owner()
	assert_not_null(owner)
	assert_true(_verifiers(setup)[0].is_ancestor_of(owner),
		"Enter now lands inside the verifier, not on the button beneath")
