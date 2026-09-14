class_name SgLobby
extends Control
## [QoL] Separate classic-styled identity, host, browser and waiting-room windows.
## Opening a menu starts no network operation. Only a saved display name persists.

var client := SgLocalClient.new()
var service: SgLocalServer
var _port: SpinBox
var _code: LineEdit
var _nickname: LineEdit
var _room_name: LineEdit
var _status: Label
var _notice: Label
var _body: VBoxContainer
var _start: Button
var _connect_button: Button
var _close_button: Button
var _lan_start: Button
var _scan: Button
var _interfaces: OptionButton
var _advertise: CheckButton
var _copy: Button
var _discovery: SgLanDiscovery
var _selected_host: Dictionary = {}
var _connection_controls: VBoxContainer
var _introduction: Label
var _shell: Control
var _window: PanelContainer
var _title: Label
var _pages: Dictionary = {}
var _page := "home"
var _remember: CheckBox
var _identity_summary: Label
var _identity_name := ""
var _room_draft := "Friendly duel"
var _redraw_queued := false
var _confirm_close := false
var _host_pending := false
var _room_id := ""
var _duel: SgDuelView
var _browser_connection: VBoxContainer
var _host_controls: VBoxContainer
var _deck_picker: Control
var _catalog: Array = []


func _ready() -> void:
	name = "SGManalinkLobby"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(client)
	client.changed.connect(_queue_refresh)
	client.refused.connect(func(reason: String) -> void:
		_host_pending = false
		_notice.text = reason
		if is_instance_valid(_duel):
			_duel.show_notice(reason))
	_shell = Control.new()
	add_child(_shell)
	_shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0.025, 0.035, 0.025, 0.96)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shell.add_child(dim)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	_window = UiChrome.panel_around(column, 20)
	_shell.add_child(_window)
	_window.minimum_size_changed.connect(func() -> void: _layout_window.call_deferred())
	var heading := HBoxContainer.new()
	column.add_child(heading)
	_title = _label("SGManalink", 28)
	_title.autowrap_mode = TextServer.AUTOWRAP_OFF
	heading.add_child(_title)
	_close_button = _button("Close", _close, Vector2(130, 38))
	heading.add_child(_close_button)
	_status = _label("Not connected", 15)
	column.add_child(_status)
	_notice = _label("", 15)
	column.add_child(_notice)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_connection_controls = VBoxContainer.new()
	_connection_controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_connection_controls.add_theme_constant_override("separation", 12)
	scroll.add_child(_connection_controls)
	for key in ["home", "identity", "host", "browser"]:
		var page := VBoxContainer.new()
		page.name = key.capitalize() + "Window"
		page.add_theme_constant_override("separation", 12)
		_connection_controls.add_child(page)
		_pages[key] = page
	_build_home(_pages.home)
	_build_identity(_pages.identity)
	_build_host(_pages.host)
	_build_browser(_pages.browser)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 12)
	_connection_controls.add_child(_body)
	resized.connect(_layout_window)
	_layout_window()
	_refresh()
	_layout_window.call_deferred()
	_close_button.grab_focus()
	get_viewport().gui_focus_changed.connect(_keep_focus)


func _layout_window() -> void:
	if _window == null:
		return
	_window.size = Vector2(minf(820, maxf(0, size.x - 32)), maxf(0, size.y - 40))
	_window.position = (size - _window.size) * 0.5


func _build_home(page: VBoxContainer) -> void:
	_introduction = _label("Welcome to SGManalink", 24)
	page.add_child(_introduction)
	page.add_child(_label("Meet across the table, wherever your LAN reaches.", 18))
	_identity_summary = _label("", 18)
	page.add_child(_identity_summary)
	for entry in [["Identity", "identity"], ["Host Game", "host"], ["Game Browser", "browser"]]:
		page.add_child(_button(entry[0], _show_page.bind(entry[1]), Vector2(280, 48)))
	page.add_child(_label("Temporary names • Friendly, unrated games\n"
		+ "Desktop LAN duels with shipped decks and your own saved decks. "
		+ "Internet discovery, verified accounts and MElo are not available yet.", 16))


func _build_identity(page: VBoxContainer) -> void:
	page.add_child(_label("Choose your name at the table", 23))
	page.add_child(_label("Create a temporary persona, or leave the name blank to play as a guest.", 16))
	_nickname = LineEdit.new()
	_nickname.name = "TemporaryName"
	_nickname.max_length = SgProtocol.NICKNAME_LIMIT
	_nickname.placeholder_text = "Your player name"
	_nickname.text = SgIdentity.remembered_name()
	_identity_name = _nickname.text
	_nickname.custom_minimum_size.y = 40
	page.add_child(_nickname)
	page.add_child(_button("Generate name", func() -> void:
		_nickname.text = SgIdentity.generate_name()))
	_remember = CheckBox.new()
	_remember.text = "Remember this name on this device"
	_remember.button_pressed = not _nickname.text.is_empty()
	UiChrome.shadowed_button(_remember)
	page.add_child(_remember)
	page.add_child(_label("A name is not a verified identity. Names are not reserved; the host adds "
		+ "a guest number to distinguish players. No account, email or SSH key is needed.", 16))
	page.add_child(_button("Use this identity", _save_identity))
	page.add_child(_button("Cancel", _show_page.bind("home")))


func _build_host(page: VBoxContainer) -> void:
	page.add_child(_label("Host a friendly duel", 23))
	page.add_child(_label("The host runs the game. Keep this window open while your opponent plays.", 16))
	_room_name = LineEdit.new()
	_room_name.name = "RoomName"
	_room_name.text = _room_draft
	_room_name.max_length = 32
	_room_name.custom_minimum_size.y = 40
	_room_name.text_changed.connect(func(value: String) -> void: _room_draft = value)
	page.add_child(_room_name)
	_host_controls = VBoxContainer.new()
	_host_controls.add_theme_constant_override("separation", 10)
	page.add_child(_host_controls)
	var row := HBoxContainer.new()
	_host_controls.add_child(row)
	row.add_child(_label("LAN address", 16))
	_interfaces = OptionButton.new()
	_interfaces.name = "LanInterface"
	_interfaces.custom_minimum_size = Vector2(220, 38)
	for address in SgLanInvite.local_addresses():
		_interfaces.add_item(address)
	if _interfaces.item_count == 0:
		_interfaces.add_item("No LAN IPv4 address")
	UiChrome.shadowed_button(_interfaces)
	row.add_child(_interfaces)
	row = HBoxContainer.new()
	_host_controls.add_child(row)
	var port_label := _label("Port", 16)
	port_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	row.add_child(port_label)
	_port = SpinBox.new()
	_port.name = "LocalPort"
	_port.min_value = 1024
	_port.max_value = 65535
	_port.value = 17897
	row.add_child(_port)
	_advertise = CheckButton.new()
	_advertise.text = "Visible in the LAN game browser"
	_advertise.button_pressed = true
	UiChrome.shadowed_button(_advertise)
	_host_controls.add_child(_advertise)
	_host_controls.add_child(_label("Visible: nearby players can find your host. Private: invitation only.\n"
		+ "Both require your private invitation to connect. Global listing is coming later.", 15))
	page.add_child(_label("Full implemented card pool • 20 life • Mana burn on\n"
		+ "Both players review the room and click Ready before the duel starts.", 16))
	_lan_start = _button("Host on LAN", _host_game)
	_lan_start.name = "StartLan"
	page.add_child(_lan_start)
	var advanced := _button("Same-computer testing", func() -> void: _start.visible = not _start.visible)
	page.add_child(advanced)
	_start = _button("Start local service", _start_service)
	_start.name = "StartService"
	_start.hide()
	page.add_child(_start)
	page.add_child(_button("Back", _show_page.bind("home")))


func _build_browser(page: VBoxContainer) -> void:
	page.add_child(_label("Find a game", 23))
	_browser_connection = VBoxContainer.new()
	_browser_connection.add_theme_constant_override("separation", 10)
	page.add_child(_browser_connection)
	_browser_connection.add_child(_label("Find nearby hosts, then paste the private invitation your opponent sends you. "
		+ "You can also connect by invitation without searching.", 16))
	_scan = _button("Find LAN games", _scan_lan)
	_browser_connection.add_child(_scan)
	_code = LineEdit.new()
	_code.name = "AccessCode"
	_code.placeholder_text = "Paste the host invitation"
	_code.max_length = SgLanInvite.MAX_LENGTH
	_code.secret = true
	_code.custom_minimum_size.y = 40
	_code.tooltip_text = "Private invitation. Never saved by the game."
	_browser_connection.add_child(_code)
	_connect_button = _button("Connect", _connect_local)
	_browser_connection.add_child(_connect_button)
	var local_row := HBoxContainer.new()
	_browser_connection.add_child(local_row)
	local_row.add_child(_label("Same-computer test port (LAN invitations include their port)", 14))
	var local_port := SpinBox.new()
	local_port.min_value = 1024
	local_port.max_value = 65535
	local_port.value = _port.value
	local_port.value_changed.connect(func(value: float) -> void: _port.value = value)
	_port.value_changed.connect(func(value: float) -> void:
		if value >= local_port.min_value:
			local_port.value = value)
	local_row.add_child(local_port)
	page.add_child(_button("Back", _show_page.bind("home")))
	# Shown in the waiting room, never exposes the invitation text.
	_copy = _button("Copy invitation", func() -> void:
		DisplayServer.clipboard_set(_code.text)
		_notice.text = "Invitation copied. Send it privately; clipboard history may retain it.")
	_connection_controls.add_child(_copy)


func _save_identity() -> void:
	if client.has_session() or client.online or service != null:
		_notice.text = "Finish this visit before changing your identity."
		return
	var result := SgIdentity.save_name(_nickname.text, _remember.button_pressed)
	if not result.is_empty():
		_notice.text = result
		return
	_nickname.text = _nickname.text.strip_edges()
	_identity_name = _nickname.text
	_show_page("home")
	_notice.text = "Identity selected. " + ("Name remembered on this device."
		if _remember.button_pressed and not _nickname.text.is_empty() else "Name used for this visit only.")


func _show_page(page: String) -> void:
	if page not in ["home", "identity", "host", "browser", "room"]:
		return
	if page == "identity" and (client.has_session() or client.online or service != null):
		_notice.text = "Your current guest name stays fixed until you disconnect."
		return
	if _page == "identity" and page != "identity":
		_nickname.text = _identity_name
	_page = page
	_notice.text = ""
	_confirm_close = false
	_refresh()
	_close_button.grab_focus()


func _keep_focus(control: Control) -> void:
	if is_inside_tree() and is_visible_in_tree() and not is_queued_for_deletion() \
		and control != null and control != self and not is_ancestor_of(control):
		_restore_focus.call_deferred()


func _restore_focus() -> void:
	if is_inside_tree() and not is_queued_for_deletion():
		if is_instance_valid(_duel):
			_duel.focus_action()
		else:
			_close_button.grab_focus()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if is_instance_valid(_duel):
			_duel.toggle_menu()
		elif _page not in ["home", "room"]:
			_show_page("home")
		else:
			_close()
		get_viewport().set_input_as_handled()


func _button(text: String, callback: Callable, minimum := Vector2(180, 38)) -> Button:
	var button := UiChrome.menu_button(text, minimum, 18)
	button.pressed.connect(callback)
	return button


func _label(text: String, font_size := 14) -> Label:
	var label := UiChrome.body_label(text, font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _host_game() -> void:
	if not SgProtocol.short_text(_room_draft.strip_edges()):
		_notice.text = "Room names use up to 32 letters, numbers, spaces, - and _."
		return
	if client.online:
		_send({"op": "host", "name": _room_draft.strip_edges()})
		return
	_host_pending = true
	_start_lan()
	if service == null:
		_host_pending = false


func _start_service() -> void:
	if service != null or not _valid_nickname():
		return
	var candidate := SgLocalServer.new()
	add_child(candidate)
	var result := candidate.start_local(int(_port.value))
	if result != OK:
		candidate.queue_free()
		_notice.text = "Cannot start on this port. Choose a free port."
		return
	service = candidate
	_port.value = service.port
	_code.text = service.access_code
	_selected_host = {}
	_notice.text = "Local service started. Use its access code and port in a second window on this computer."
	_connect_local()


func _start_lan() -> void:
	if service != null or not _valid_nickname():
		return
	var address := _interfaces.get_item_text(_interfaces.selected)
	if not SgLanInvite.local_addresses().has(address):
		_notice.text = "Connect this computer to a private IPv4 LAN first."
		return
	var candidate := SgLocalServer.new()
	add_child(candidate)
	var result := candidate.start_lan(address, int(_port.value), _advertise.button_pressed,
		_nickname.text.strip_edges())
	if result != OK:
		candidate.queue_free()
		_notice.text = "Cannot host on this address and port. Check the network or choose another port."
		return
	service = candidate
	_port.value = service.port
	_code.text = service.invitation()
	_selected_host = {}
	_notice.text = "LAN host started. Copy invitation to your opponent. Closing ends all hosted games."
	if service.discovery_error != OK:
		_notice.text += " Discovery is unavailable; the invitation still connects directly."
	_connect_local()


func _scan_lan() -> void:
	if _discovery == null:
		_discovery = SgLanDiscovery.new()
		add_child(_discovery)
		_discovery.changed.connect(_queue_refresh)
	if _discovery.scanning:
		_discovery.stop()
		_selected_host = {}
	else:
		var result := _discovery.scan()
		_notice.text = "Searching the LAN. Ask the host for their private invitation." \
			if result == OK else "Cannot scan this network. Connect by invitation instead."
	_refresh()


func _connect_local() -> void:
	if client.online or client.busy():
		return
	if client.has_session():
		client.reconnect()
		return
	if not _valid_nickname():
		return
	var invitation := _code.text.strip_edges()
	var result: Error
	if invitation.begins_with(SgLanInvite.PREFIX):
		var data := SgLanInvite.parse(invitation)
		if not _selected_host.is_empty() and (data.is_empty() \
			or data.address != _selected_host.address or data.port != _selected_host.port \
			or data.fingerprint != _selected_host.fingerprint):
			_notice.text = "This invitation does not match the selected host. Clear the selection to join it directly."
			return
		result = client.connect_invitation(invitation, _nickname.text)
	else:
		if not _selected_host.is_empty():
			_notice.text = "Paste the complete LAN invitation from the host, not a local access code."
			return
		result = client.connect_local(int(_port.value), invitation, _nickname.text)
	if result != OK:
		_notice.text = "Paste a complete invitation from the current host. LAN play requires the desktop game."


func _valid_nickname() -> bool:
	if SgProtocol.nickname(_nickname.text.strip_edges()):
		return true
	_notice.text = "Temporary names use up to 20 letters, numbers, spaces, - or _. Leave blank for a guest name."
	return false


func _close() -> void:
	var room: Dictionary = client.state.room
	if not _confirm_close and (service != null or not room.is_empty() or client.has_session()):
		_confirm_close = true
		_close_button.text = "Confirm close"
		_notice.text = "Closing forgets this temporary seat. If you host, all your games end. "
		_notice.text += "Click Confirm close to continue."
		return
	queue_free()


func _queue_refresh() -> void:
	if not _redraw_queued:
		_redraw_queued = true
		_refresh.call_deferred()


func _refresh() -> void:
	_redraw_queued = false
	if not is_inside_tree():
		return
	var room: Dictionary = client.state.room
	if _host_pending and client.online and not client.busy() and room.is_empty():
		_host_pending = false
		_send({"op": "host", "name": _room_draft.strip_edges()})
	if not room.is_empty():
		_page = "room"
	elif not _room_id.is_empty():
		_page = "browser"
	_room_id = String(room.get("id", ""))
	var playing: bool = not room.is_empty() and not room.game.is_empty()
	if playing:
		_close_decks()
		if not is_instance_valid(_duel):
			_duel = SgDuelView.new()
			add_child(_duel)
			_duel.action_requested.connect(_send)
			_duel.reconnect_requested.connect(client.reconnect)
			_duel.exit_requested.connect(func() -> void: queue_free())
		_duel.present(room, client.online, client.busy(), service != null)
	elif is_instance_valid(_duel):
		_duel.queue_free()
		_duel = null
	_shell.visible = not playing
	_connection_controls.visible = not playing
	_status.text = client.status + (" - " + client.guest if client.online else "")
	_identity_summary.text = "Playing as: " + (_nickname.text if not _nickname.text.is_empty() else "Guest")
	var locked := client.online or client.has_session() or service != null
	_nickname.editable = not locked
	_start.disabled = locked or OS.has_feature("web")
	_lan_start.disabled = client.busy() or OS.has_feature("web") \
		or (not client.online and (locked or not SgLanInvite.address(_interfaces.get_item_text(_interfaces.selected))))
	_lan_start.text = "Host a duel" if client.online else "Host on LAN"
	_interfaces.disabled = locked
	_advertise.disabled = locked
	_port.editable = not locked
	_host_controls.visible = not client.online
	_scan.disabled = client.online or client.has_session() or OS.has_feature("web")
	_scan.text = "Stop LAN search" if _discovery != null and _discovery.scanning else "Find LAN games"
	if (_page != "browser" or client.online) and _discovery != null and _discovery.scanning:
		_discovery.stop()
	_connect_button.disabled = client.online or client.busy()
	_connect_button.text = "Connected" if client.online else ("Reconnect" if client.has_session() else "Connect")
	_code.editable = not locked
	_browser_connection.visible = not client.online
	_copy.visible = service != null and not playing
	_copy.disabled = _code.text.is_empty()
	_close_button.text = "Confirm close" if _confirm_close else "Close"
	_title.text = {"home": "SGManalink", "identity": "Identity", "host": "Host Game",
		"browser": "Game Browser", "room": "Duel room"}[_page]
	for key in _pages:
		_pages[key].visible = key == _page
	for child in _body.get_children():
		_body.remove_child(child)
		child.queue_free()
	if playing:
		return
	if _page == "room":
		_waiting_room(room)
	elif _page == "browser":
		_browser()
	elif _page == "home" and locked:
		_body.add_child(_button("Disconnect", _disconnect))


func _disconnect() -> void:
	if service != null:
		service.stop()
		service.queue_free()
		service = null
	client.forget()
	_code.text = ""
	_selected_host.clear()
	_host_pending = false
	_show_page("home")


func _waiting_room(room: Dictionary) -> void:
	_body.add_child(_label(String(room.name), 24))
	for seat in 2:
		_body.add_child(_label("%s%s - %s\nDeck: %s" % [room.names[seat],
			" (you)" if seat == int(room.seat) else "",
			"Ready" if room.ready[seat] else ("Choosing" if room.connected[seat] else "Waiting for player"), room.deck_names[seat]], 18))
	_body.add_child(_label("Unrestricted • 40-250 cards • 20 life • Mana burn on\n"
		+ "Free combat damage assignment • Single friendly duel\n"
		+ "Choose any implemented deck. Deck contents go only to the referee, not your opponent.\n"
		+ "Both players must be ready to begin. Changing a deck clears both Ready marks.", 16))
	var decks := _button("Choose / review deck", _open_decks)
	decks.disabled = not client.online or client.busy()
	_body.add_child(decks)
	var ready := _button("Not ready" if room.ready[int(room.seat)] else "Ready", func() -> void:
		_send({"op": "ready", "value": not room.ready[int(room.seat)]}))
	ready.disabled = not client.online or client.busy()
	_body.add_child(ready)
	var leave := _button("Leave room", func() -> void: _send({"op": "leave"}))
	leave.disabled = not client.online or client.busy()
	_body.add_child(leave)
	if not client.online:
		_body.add_child(_button("Reconnect", client.reconnect))


func _close_decks() -> void:
	if is_instance_valid(_deck_picker):
		_deck_picker.queue_free()
		_deck_picker = null


func _open_decks() -> void:
	_close_decks()
	if _catalog.is_empty(): _catalog = SgDeckCatalog.available()
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.85)
	add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_deck_picker = overlay
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	var panel := UiChrome.panel_around(column, 16)
	overlay.add_child(panel)
	panel.size = Vector2(minf(780, size.x - 48), size.y - 64)
	panel.position = (size - panel.size) * 0.5
	column.add_child(_label("Choose your deck", 24))
	var search := LineEdit.new()
	search.placeholder_text = "Search shipped and saved decks"
	column.add_child(search)
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(row)
	var list := ItemList.new()
	list.name = "NetworkDeckList"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.custom_minimum_size.x = 240
	row.add_child(list)
	var details := RichTextLabel.new()
	details.name = "NetworkDeckContents"
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.custom_minimum_size.x = 200
	details.add_theme_color_override("default_color", UiChrome.INK)
	details.add_theme_color_override("font_shadow_color", UiChrome.SEAT)
	details.add_theme_constant_override("shadow_offset_x", 1)
	details.add_theme_constant_override("shadow_offset_y", 1)
	var font := GameSkin.font("font_body")
	if font != null: details.add_theme_font_override("normal_font", font)
	row.add_child(details)
	var selected := {"deck": {}}
	var use := _button("Use this deck", func() -> void:
		if selected.deck.is_empty(): return
		_send({"op": "deck", "name": selected.deck.name, "cards": selected.deck.cards, "sideboard": selected.deck.sideboard})
		_close_decks())
	use.disabled = true
	column.add_child(use)
	column.add_child(_button("Back", _close_decks))
	var show_deck := func(deck: Dictionary) -> void:
		selected.deck = deck
		details.text = _deck_text(deck)
		use.disabled = false
	list.item_selected.connect(func(index: int) -> void: show_deck.call(_catalog[int(list.get_item_metadata(index))]))
	var refill := func(query: String) -> void:
		list.clear()
		for index in _catalog.size():
			var deck: Dictionary = _catalog[index]
			if not query.is_empty() and not String(deck.name).to_lower().contains(query.to_lower()): continue
			list.add_item("%s (%d)" % [deck.name, deck.cards.size()])
			list.set_item_metadata(list.item_count - 1, index)
			list.set_item_tooltip(list.item_count - 1, deck.group)
	search.text_changed.connect(refill)
	refill.call("")
	if not client.state.room.deck.is_empty(): show_deck.call(client.state.room.deck)
	search.grab_focus()


static func _deck_text(deck: Dictionary) -> String:
	var result := "%s\n%d cards · %d sideboard\n" % [deck.name, deck.cards.size(), deck.sideboard.size()]
	for zone in ["cards", "sideboard"]:
		var counts := {}
		for card_name in deck[zone]: counts[card_name] = int(counts.get(card_name, 0)) + 1
		var names := counts.keys()
		names.sort()
		result += "\nMain deck\n" if zone == "cards" else "\nSideboard (not used in a single duel)\n"
		for card_name in names: result += "%d  %s\n" % [counts[card_name], card_name]
	return result


func _browser() -> void:
	if not client.online:
		_body.add_child(_label("Nearby hosts", 23))
		if not _selected_host.is_empty():
			_body.add_child(_label("Selected: %s - %s:%d" % [
				_selected_host.name, _selected_host.address, int(_selected_host.port)], 16))
			_body.add_child(_button("Clear selection", func() -> void:
				_selected_host = {}
				_refresh()))
		if _discovery == null or _discovery.hosts.is_empty():
			_body.add_child(_label("No hosts listed. Search the LAN or connect by invitation.", 16))
		else:
			var keys := _discovery.hosts.keys()
			keys.sort()
			for key in keys:
				var advert: Dictionary = _discovery.hosts[key].host
				var row := HBoxContainer.new()
				_body.add_child(row)
				row.add_child(_label("%s\n%s:%d - %d open room(s)" % [advert.name, advert.address,
					int(advert.port), int(advert.rooms)], 16))
				row.add_child(_button("Select", func() -> void:
					_selected_host = advert.duplicate(true)
					_refresh(), Vector2(120, 38)))
		return
	_body.add_child(_label("Available duels", 23))
	if client.state.rooms.is_empty():
		_body.add_child(_label("No duels yet. Your host can create one in Host Game.", 16))
	for room: Dictionary in client.state.rooms:
		var line := HBoxContainer.new()
		_body.add_child(line)
		line.add_child(_label("%s\nHost: %s" % [room.name, room.host], 18))
		var join := _button("Join" if room.open else "In use", func() -> void:
			_send({"op": "join", "room": room.id}), Vector2(120, 38))
		join.disabled = client.busy() or not room.open
		line.add_child(join)


func _send(action: Dictionary) -> void:
	_confirm_close = false
	_notice.text = ""
	if not client.command(action):
		var reason := "Wait for the connection or the current action."
		_notice.text = reason
		if is_instance_valid(_duel):
			_duel.show_notice(reason)
