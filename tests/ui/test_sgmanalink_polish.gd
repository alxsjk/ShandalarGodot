extends GameTest
## Lobby lifecycle, terminal network responses and stable, responsive menu controls.

var server: SgLocalServer
var client: SgLocalClient

class DelayedServer extends SgLocalServer:
	var held: Dictionary = {}
	var hold_states := false
	var acknowledgements := 0
	func _send(id: int, message: Dictionary) -> void:
		if message.type == "ack": acknowledgements += 1
		if hold_states and message.type == "state":
			held[id] = message.duplicate(true)
			return
		super._send(id, message)
	func release() -> void:
		hold_states = false
		for id in held: _send(id, held[id])
		held.clear()

func _until(predicate: Callable) -> void:
	for i in 400:
		if predicate.call(): return
		await get_tree().process_frame
	assert_true(false, "Network menu check exceeded its frame budget")

func _pump() -> void:
	for i in 8: await get_tree().process_frame

func _connect() -> void:
	server = SgLocalServer.new()
	add_child_autofree(server)
	assert_eq(server.start_local(0), OK)
	client = SgLocalClient.new()
	add_child_autofree(client)
	assert_eq(client.connect_local(server.port, server.access_code), OK)
	for i in 400:
		if client.online: return
		await get_tree().process_frame
	assert_true(false, "Connection exceeded its frame budget")

func _lobby() -> SgLobby:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 600)
	add_child_autofree(viewport)
	var lobby := SgLobby.new()
	viewport.add_child(lobby)
	lobby.client.state.room = {"id":"r1", "name":"Evening Magic", "seat":0,
		"names":["Azure Fox", "Amber Owl"], "revision":1, "ready":[false,false],
		"connected":[true,true], "game":{}, "deck_names":["Knights","Raiders"], "deck":{}}
	lobby._show_page("room")
	return lobby

func test_fatal_response_cannot_be_undone_by_queued_state() -> void:
	await _connect()
	client.set_process(false)
	var sid: int = server._tokens[client._resume.sha256_text()]
	var peer: int = server._sessions[sid].peer
	server._send(peer, {"type":"fatal", "error":"Visit ended."})
	server._send(peer, server._state(sid))
	await _pump()
	client.poll()
	assert_false(client.online)
	assert_false(client._wanted)
	assert_eq(client.status, "Visit ended.")

func test_refusal_callback_can_disconnect_without_reviving_old_state() -> void:
	await _connect()
	client.refused.connect(func(_reason: String) -> void: client.forget())
	assert_true(client.command({"op":"pass"}))
	await _pump()
	assert_false(client.online)
	assert_false(client._wanted)
	assert_true(client.state.room.is_empty())
	assert_eq(client.status, "Not connected")

func test_connecting_callback_can_cancel_the_attempt() -> void:
	server = SgLocalServer.new()
	add_child_autofree(server)
	assert_eq(server.start_local(0), OK)
	client = SgLocalClient.new()
	add_child_autofree(client)
	client.changed.connect(func() -> void: client.forget())
	assert_eq(client.connect_local(server.port, server.access_code), OK)
	await _pump()
	assert_false(client.online)
	assert_false(client.connecting())
	assert_null(client._socket)
	assert_eq(client.status, "Not connected")

func test_loss_callback_reconnect_starts_only_one_replacement_socket() -> void:
	await _connect()
	client.set_process(false)
	var attempts: Array = []
	client.changed.connect(func() -> void:
		if client.status == "Connection lost; reconnecting...": client.reconnect()
		elif client.status.begins_with("Connecting"): attempts.append(client._socket))
	client._socket.close(-1)
	client.poll()
	assert_eq(attempts.size(), 1, "callback reconnect must not trigger another retry in the old poll")
	assert_same(client._socket, attempts[0])
	client.forget()

func test_unchanged_waiting_room_keeps_its_widgets() -> void:
	var lobby := _lobby()
	var first: Node = lobby._body.get_child(0)
	lobby._refresh()
	assert_same(lobby._body.get_child(0), first)

func test_an_empty_seat_shows_no_deck_title() -> void:
	# The seat view keeps the referee's default "Forest practice" for a
	# player who has not chosen yet — honest, since that IS what they
	# would play. An EMPTY seat has nobody to play it, so the host who
	# just watched their guest leave used to read a deck title under
	# nobody; the lobby now draws a dash there (2026-09-17, item 5).
	var lobby := _lobby()
	lobby.client.state.room.names = ["Azure Fox", "Empty seat"]
	lobby.client.state.room.connected = [true, false]
	lobby.client.state.room.deck_names = ["Knights", "Forest practice"]
	lobby._refresh()
	var lines: Array = []
	for node in lobby._body.find_children("*", "Label", true, false):
		if String(node.text).begins_with("Deck: "): lines.append(String(node.text))
	assert_eq(lines, ["Deck: Knights", "Deck: —"])
	lobby.client.state.room.names = ["Azure Fox", "Amber Owl"]
	lobby.client.state.room.connected = [true, true]
	lobby._refresh()
	lines.clear()
	for node in lobby._body.find_children("*", "Label", true, false):
		if String(node.text).begins_with("Deck: "): lines.append(String(node.text))
	assert_eq(lines, ["Deck: Knights", "Deck: Forest practice"],
		"a seated player who has not chosen still reads the honest default")

func test_deck_chooser_closes_when_its_room_disappears() -> void:
	var lobby := _lobby()
	lobby._open_decks()
	assert_true(is_instance_valid(lobby._deck_picker))
	lobby.client.state.room = {}
	lobby._refresh()
	assert_false(is_instance_valid(lobby._deck_picker))

func test_escape_closes_deck_chooser_not_the_visit() -> void:
	var lobby := _lobby()
	lobby._open_decks()
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	lobby._unhandled_key_input(event)
	assert_false(is_instance_valid(lobby._deck_picker))
	assert_false(lobby._confirm_close)
	assert_eq(lobby._page, "room")

func test_hidden_search_result_is_not_still_selected_for_submission() -> void:
	var lobby := _lobby()
	lobby._open_decks()
	var list := lobby._deck_picker.find_child("NetworkDeckList", true, false) as ItemList
	list.select(0)
	list.item_selected.emit(0)
	var search: LineEdit
	for node in lobby._deck_picker.find_children("*", "LineEdit", true, false): search = node
	search.text = "No deck matches this phrase"
	search.text_changed.emit(search.text)
	var use: Button
	for node in lobby._deck_picker.find_children("*", "Button", true, false):
		if node.text == "Use this deck": use = node
	assert_true(use.disabled, "an invisible old result must not be submitted")

func test_identity_cannot_change_during_an_initial_connection_attempt() -> void:
	var lobby := _lobby()
	lobby.client.state.room = {}
	lobby.client._wanted = true
	lobby._refresh()
	assert_false(lobby._nickname.editable)
	lobby._show_page("identity")
	assert_ne(lobby._page, "identity")
	lobby._disconnect()
	assert_true(lobby._nickname.editable)

func test_deck_overlay_refits_when_the_viewport_changes() -> void:
	var lobby := _lobby()
	lobby._open_decks()
	await _pump()
	(lobby.get_parent() as SubViewport).size = Vector2i(800, 540)
	await _pump()
	assert_lte(lobby._deck_panel.get_rect().end.x, 800.0)
	assert_lte(lobby._deck_panel.get_rect().end.y, 540.0)
	assert_gte(lobby._deck_panel.position.x, 0.0)

func test_waiting_room_busy_updates_keep_controls_and_disable_commands() -> void:
	var lobby := _lobby()
	lobby.client.online = true
	lobby._refresh()
	var first: Node = lobby._body.get_child(0)
	lobby.client._pending = {"seq":1}
	lobby._refresh()
	assert_same(lobby._body.get_child(0), first)
	for node in lobby._body.find_children("*", "Button", true, false):
		if node.has_meta("network_action"): assert_true(node.disabled)
	lobby.client._pending.clear()
	lobby._refresh()
	assert_same(lobby._body.get_child(0), first)

func test_deck_choice_waits_for_host_confirmation_and_survives_refusal() -> void:
	var host := DelayedServer.new()
	add_child_autofree(host)
	assert_eq(host.start_local(0), OK)
	var lobby := _lobby()
	lobby.client.state = {"room":{}, "rooms":[]}
	assert_eq(lobby.client.connect_local(host.port, host.access_code), OK)
	await _until(func() -> bool: return lobby.client.online)
	assert_true(lobby.client.command({"op": "host", "name": "Deck approval", "decks": "own", "deck": {}}))
	await _until(func() -> bool: return not lobby.client.busy())
	await _pump()
	lobby._open_decks()
	var list := lobby._deck_picker.find_child("NetworkDeckList", true, false) as ItemList
	list.select(0)
	list.item_selected.emit(0)
	var chosen := lobby._deck_selected.duplicate(true)
	host.hold_states = true
	var acks := host.acknowledgements
	lobby._deck_use.pressed.emit()
	await _until(func() -> bool: return host.acknowledgements > acks)
	await _pump()
	assert_true(is_instance_valid(lobby._deck_picker), "ACK alone is not deck confirmation")
	assert_true(lobby._deck_use.disabled)
	host.release()
	await _until(func() -> bool: return not lobby.client.busy())
	await _pump()
	assert_false(is_instance_valid(lobby._deck_picker))
	assert_eq(lobby.client.state.room.deck, chosen)
	lobby._open_decks()
	lobby._deck_selected = {"name":"Invalid", "cards":["Missing card"], "sideboard":[]}
	lobby._deck_use.pressed.emit()
	await _until(func() -> bool: return not lobby.client.busy())
	await _pump()
	assert_true(is_instance_valid(lobby._deck_picker), "a refusal keeps the picker and selection")
	assert_eq(lobby._deck_selected.name, "Invalid")
	assert_false(lobby._deck_status.text.is_empty())
	lobby.client.forget()
	host.stop()

func test_identity_cancel_restores_the_remember_choice_without_writing() -> void:
	var lobby := _lobby()
	lobby.client.state.room = {}
	lobby._show_page("home")
	lobby._show_page("identity")
	assert_eq(lobby._page, "identity")
	var remembered := lobby._remember.button_pressed
	var writes := Settings.write_count
	lobby._remember.button_pressed = not remembered
	lobby._show_page("home")
	assert_eq(lobby._remember.button_pressed, remembered)
	assert_eq(Settings.write_count, writes)

func test_menu_fields_fit_small_viewports_and_focused_buttons_keep_dark_ink() -> void:
	var lobby := _lobby()
	lobby.client.state.room = {}
	assert_eq(lobby._close_button.get_theme_color("font_focus_color"), UiChrome.INK)
	for dimensions in [Vector2i(960,600), Vector2i(800,540), Vector2i(640,480)]:
		(lobby.get_parent() as SubViewport).size = dimensions
		for page in ["home", "identity", "host", "browser"]:
			lobby._show_page(page)
			await _pump()
			var window: Rect2 = lobby._window.get_global_rect()
			assert_lte(window.end.x, float(dimensions.x))
			assert_lte(window.end.y, float(dimensions.y))
			for node in lobby._connection_controls.find_children("*", "LineEdit", true, false):
				if node.is_visible_in_tree():
					assert_lte(node.get_global_rect().end.x, window.end.x)
