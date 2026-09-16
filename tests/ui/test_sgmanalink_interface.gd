extends GameTest
## Classic menus and data-only duel controls. Player preferences are restored.

var _saved_name: Variant
var _had_name := false


func before_each() -> void:
	super.before_each()
	_had_name = Settings.has_value(SgIdentity.KEY)
	_saved_name = Settings.get_value(SgIdentity.KEY, "")
	Settings.clear_value(SgIdentity.KEY)


func after_each() -> void:
	if _had_name:
		Settings.set_value(SgIdentity.KEY, _saved_name)
	else:
		Settings.clear_value(SgIdentity.KEY)
	super.after_each()


func _lobby() -> SgLobby:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 600)
	add_child_autofree(viewport)
	var lobby := SgLobby.new()
	viewport.add_child(lobby)
	return lobby


func _room(duel: SgPracticeMatch, seat: int, revision := 1) -> Dictionary:
	return {"id": "r1", "name": "Friendly duel", "seat": seat,
		"names": ["Azure Fox (Guest 1)", "Amber Owl (Guest 2)"], "revision": revision,
		"ready": [true, true], "connected": [true, true], "game": duel.view(seat),
		"deck_names": duel.deck_names.duplicate(), "deck": {}}


func _screen() -> SgDuelView:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 600)
	add_child_autofree(viewport)
	var screen := SgDuelView.new()
	viewport.add_child(screen)
	return screen


func test_deck_selector_lists_shipped_decks_and_full_contents() -> void:
	var lobby := _lobby()
	lobby.client.online = true
	lobby.client.state.room = {"id":"r1", "name":"Friendly duel", "seat":0,
		"names":["Azure Fox", "Amber Owl"], "revision":1, "ready":[false,false],
		"connected":[true,true], "game":{}, "deck_names":["Knights","Raiders"], "deck":{}}
	lobby._open_decks()
	for i in 5: await get_tree().process_frame
	var list := lobby._deck_picker.find_child("NetworkDeckList", true, false) as ItemList
	assert_gt(list.item_count, 100)
	list.select(0)
	list.item_selected.emit(0)
	var contents := lobby._deck_picker.find_child("NetworkDeckContents", true, false) as RichTextLabel
	assert_string_contains(contents.text, "Main deck")
	assert_false(_button(lobby, "Use this deck").disabled)
	lobby._close_decks()


func _button(root: Node, text: String) -> Button:
	for node in root.find_children("*", "Button", true, false):
		if node.text == text and node.is_visible_in_tree():
			return node
	return null


func test_identity_is_optional_local_and_only_saved_on_confirmation() -> void:
	var lobby := _lobby()
	var writes := Settings.write_count
	lobby._show_page("identity")
	assert_false(Settings.has_value(SgIdentity.KEY))
	assert_eq(Settings.write_count, writes)
	_button(lobby, "Generate name").pressed.emit()
	assert_true(SgProtocol.nickname(lobby._nickname.text))
	assert_false(lobby._nickname.text.is_empty())
	assert_false(Settings.has_value(SgIdentity.KEY), "generation is not a save or an account")
	lobby._nickname.text = "Azure Fox"
	lobby._remember.button_pressed = true
	_button(lobby, "Use this identity").pressed.emit()
	assert_eq(lobby._page, "home")
	assert_eq(SgIdentity.remembered_name(), "Azure Fox")
	assert_null(lobby.service)
	assert_null(lobby._discovery)
	assert_false(lobby.client._wanted)
	var reopened := _lobby()
	assert_eq(reopened._nickname.text, "Azure Fox")
	lobby._show_page("identity")
	lobby._nickname.text = "Unsaved edit"
	_button(lobby, "Cancel").pressed.emit()
	assert_eq(lobby._nickname.text, "Azure Fox")
	assert_eq(SgIdentity.remembered_name(), "Azure Fox")
	lobby._show_page("identity")
	lobby._nickname.text = "Guest Fox"
	lobby._remember.button_pressed = false
	_button(lobby, "Use this identity").pressed.emit()
	assert_false(Settings.has_value(SgIdentity.KEY))
	assert_eq(lobby._nickname.text, "Guest Fox")
	assert_eq(_lobby()._nickname.text, "")


func test_invalid_identity_and_saved_setting_are_not_trusted() -> void:
	Settings.set_value(SgIdentity.KEY, {"name": "bad"})
	assert_eq(SgIdentity.remembered_name(), "")
	var lobby := _lobby()
	lobby._show_page("identity")
	lobby._nickname.text = "[admin]"
	lobby._save_identity()
	assert_eq(lobby._page, "identity")
	assert_string_contains(lobby._notice.text, "letters")
	assert_eq(SgIdentity.remembered_name(), "")
	for i in 80:
		assert_true(SgProtocol.nickname(SgIdentity.generate_name()))


func test_windows_are_separate_fit_and_do_not_open_sockets() -> void:
	var lobby := _lobby()
	for page in ["home", "identity", "host", "browser"]:
		lobby._show_page(page)
		for i in 5:
			await get_tree().process_frame
		for key in lobby._pages:
			assert_eq(lobby._pages[key].visible, key == page)
		assert_lte(lobby._window.get_rect().end.x, 960.0)
		assert_lte(lobby._window.get_rect().end.y, 600.0)
		assert_gte(lobby._window.position.x, 0.0)
		assert_null(lobby.service)
		assert_null(lobby._discovery)
		assert_false(lobby.client._wanted)
	assert_true(lobby._advertise.button_pressed)
	lobby._advertise.button_pressed = false
	assert_false(lobby._advertise.button_pressed, "private hosting is explicit")


func test_overview_gives_guidance_without_repeating_navigation() -> void:
	var lobby := _lobby()
	var home: Control = lobby._pages.home
	assert_eq(home.find_children("*", "Button", true, false).size(), 0,
		"Overview explains the visit; navigation belongs only in the top tabs")
	assert_eq(lobby._navigation.size(), 5)
	var explanation := ""
	for label in home.find_children("*", "Label", true, false):
		explanation += label.text + "\n"
	for fact in ["same local network", "same game build", "private invitation", "Ready", "referee"]:
		assert_string_contains(explanation, fact)
	for dimensions in [Vector2i(1280,800), Vector2i(960,600), Vector2i(640,480)]:
		(lobby.get_parent() as SubViewport).size = dimensions
		for i in 5: await get_tree().process_frame
		var window := lobby._window.get_global_rect()
		assert_gte(window.position.x, 0.0)
		assert_lte(window.end.x, float(dimensions.x))
		assert_lte(window.end.y, float(dimensions.y))
		for label in home.find_children("*", "Label", true, false):
			assert_gte(label.get_global_rect().position.x, window.position.x)
			assert_lte(label.get_global_rect().end.x, window.end.x)
	assert_null(lobby.service)
	assert_null(lobby._discovery)
	assert_false(lobby.client._wanted)
