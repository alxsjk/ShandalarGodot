extends GutTest
## Pack 1's title-screen door and the live count requested by the owner.


func before_each() -> void:
	CardPacks.set_enabled(CardPacks.ID, false)


func after_each() -> void:
	CardPacks.set_enabled(CardPacks.ID, false)
	ShellMusic.stop()


func _title() -> Control:
	var screen: Control = load("res://game/main.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame
	return screen


func _button(root: Node, name: String) -> Button:
	return root.find_child(name, true, false) as Button


func test_present_pack_keeps_the_set_strip_compact() -> void:
	var title := await _title()
	var pack := _button(title, "Pack1")
	assert_not_null(pack)
	if pack == null:
		return
	assert_lt(pack.size.y, pack.size.x, "the pack badge is rectangular")
	assert_eq(pack.text, "1-tDotP")
	assert_string_contains(pack.tooltip_text, "disabled")
	var pool := title.find_child("CardPool", true, false) as HBoxContainer
	assert_not_null(pool)
	var plaque := pool.get_child(0) as Control
	assert_almost_eq(plaque.size.y, plaque.get_combined_minimum_size().y, 1.0,
		"the pack button does not stretch the set plaque vertically")
	assert_lte(pool.size.y, plaque.get_combined_minimum_size().y,
		"the pack keeps the strip at the original set plaque's natural height")
	assert_true(pack.get_global_rect().position.x >
		plaque.get_global_rect().end.x,
		"the numbered badge sits beside the set plaque")


func test_popup_explains_the_pack_and_has_enable_disable_buttons() -> void:
	var title := await _title()
	_button(title, "Pack1").pressed.emit()
	await get_tree().process_frame
	var popup: Control = title._pack_notice
	assert_true(is_instance_valid(popup))
	var words := ""
	for label in popup.find_children("*", "Label", true, false):
		words += (label as Label).text + "\n"
	assert_string_contains(words, "373 named set entries")
	assert_string_contains(words, "1,270 set entries")
	assert_string_contains(words, "1,305 published")
	assert_string_contains(words, "Chaos Orb")
	assert_string_contains(words, "digital adaptations")
	assert_false(_button(popup, "Enable").disabled)
	assert_true(_button(popup, "Disable").disabled)
	assert_not_null(_button(popup, "Close"))


func test_enable_and_disable_refresh_the_bottom_right_count_live() -> void:
	var title := await _title()
	var version := title.find_child("Version", true, false) as Label
	assert_string_contains(version.text, "897 cards")
	_button(title, "Pack1").pressed.emit()
	await get_tree().process_frame
	_button(title._pack_notice, "Enable").pressed.emit()
	await get_tree().process_frame
	assert_string_contains(version.text, "1,270 set entries · 901 unique cards")
	assert_true(CardRegistry.has_card("Falling Star"))
	assert_string_contains(_button(title, "Pack1").tooltip_text, "enabled")

	_button(title, "Pack1").pressed.emit()
	await get_tree().process_frame
	assert_true(_button(title._pack_notice, "Enable").disabled)
	assert_false(_button(title._pack_notice, "Disable").disabled)
	_button(title._pack_notice, "Disable").pressed.emit()
	await get_tree().process_frame
	assert_string_contains(version.text, "897 cards")
	assert_false(CardRegistry.has_card("Falling Star"))
