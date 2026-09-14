class_name SgLocalServer
extends Node
## [QoL] Volatile loopback/LAN referee. Not a public authentication service.
## Access and resume capabilities live in memory, never game settings or duel logs.
## LAN binds one private IPv4 address, uses TLS, and never opens router ports.

const MAX_CONNECTIONS := 8
const MAX_SESSIONS := 16
const MAX_ROOMS := 8
const ACK_WINDOW := 128
var port := 0
var access_code := ""
var _listener := TCPServer.new()
var _peers: Dictionary = {}
var _sessions: Dictionary = {}
var _tokens: Dictionary = {}
var _rooms: Dictionary = {}
var _next_peer := 1
var _next_session := 1
var _next_room := 1
var lan_address := ""
var lan_certificate: X509Certificate
var _lan_pem := ""
var discovery: SgLanDiscovery
var discovery_error := OK
var _tls_options: TLSOptions


func start_lan(address: String, requested_port := 17897, visible := true, nickname := "") -> Error:
	if OS.has_feature("web") or _listener.is_listening():
		return ERR_UNAVAILABLE
	if not SgLanInvite.address(address) or not IP.get_local_addresses().has(address) \
		or not SgProtocol.integer(requested_port, 0, 65535) or not SgProtocol.nickname(nickname):
		return ERR_INVALID_PARAMETER
	var crypto := Crypto.new()
	var key := crypto.generate_rsa(2048)
	if key == null:
		return ERR_CANT_CREATE
	# Wide clock tolerance; the key and invitation die when the host stops.
	var certificate := crypto.generate_self_signed_certificate(key,
		"CN=" + SgLanInvite.COMMON_NAME + ",O=SGManalink,C=XX", "20200101000000", "20400101000000")
	if certificate == null:
		return ERR_CANT_CREATE
	var pem := SgLanInvite.public_pem(certificate)
	if pem.is_empty():
		return ERR_CANT_CREATE
	var result := _listener.listen(requested_port, address)
	if result != OK:
		return result
	lan_address = address
	lan_certificate = certificate
	_lan_pem = pem
	_tls_options = TLSOptions.server(key, certificate)
	port = _listener.get_local_port()
	access_code = crypto.generate_random_bytes(32).hex_encode()
	if not SgProtocol.token(access_code):
		stop()
		return ERR_CANT_CREATE
	if visible:
		discovery = SgLanDiscovery.new()
		add_child(discovery)
		discovery_error = discovery.advertise({"address": address, "port": port,
			"name": nickname if not nickname.is_empty() else "Guest host",
			"fingerprint": pem.sha256_text(), "rooms": 0})
	return OK


func invitation() -> String:
	return SgLanInvite.create(lan_address, port, access_code, _lan_pem)


func start_local(requested_port := 17897) -> Error:
	if OS.has_feature("web") or _listener.is_listening():
		return ERR_UNAVAILABLE
	if requested_port < 0 or requested_port > 65535:
		return ERR_INVALID_PARAMETER
	var secret := Crypto.new().generate_random_bytes(32)
	if secret.size() != 32:
		return ERR_CANT_CREATE
	var result := _listener.listen(requested_port, "127.0.0.1")
	if result != OK:
		return result
	port = _listener.get_local_port()
	access_code = secret.hex_encode()
	return OK


func stop() -> void:
	_listener.stop()
	if discovery != null:
		discovery.stop()
		discovery.queue_free()
		discovery = null
	for peer: Dictionary in _peers.values():
		peer.socket.close(-1)
	_peers.clear()
	_sessions.clear()
	_tokens.clear()
	_rooms.clear()
	access_code = ""
	port = 0
	lan_address = ""
	lan_certificate = null
	_lan_pem = ""
	_tls_options = null
	discovery_error = OK


func _exit_tree() -> void:
	stop()


func _process(_delta: float) -> void:
	poll()


func poll() -> void:
	if not _listener.is_listening():
		return
	var now := Time.get_ticks_msec()
	if discovery != null:
		var available := 0
		for room: Dictionary in _rooms.values():
			if room.match == null and room.seats[1] == 0 and _connected(room.seats[0]):
				available += 1
		discovery.update_rooms(available)
	# Bounded work per frame, even if an unauthenticated local process floods us.
	for i in 8:
		if not _listener.is_connection_available():
			break
		var stream := _listener.take_connection()
		if _peers.size() >= MAX_CONNECTIONS or (not lan_address.is_empty() \
			and not SgLanInvite.address(stream.get_connected_host())):
			stream.disconnect_from_host()
			continue
		var transport: StreamPeer = stream
		if _tls_options != null:
			var tls := StreamPeerTLS.new()
			if tls.accept_stream(stream, _tls_options) != OK:
				stream.disconnect_from_host()
				continue
			transport = tls
		var socket := WebSocketPeer.new()
		socket.supported_protocols = PackedStringArray([SgProtocol.SUBPROTOCOL])
		socket.inbound_buffer_size = 65536
		socket.outbound_buffer_size = SgProtocol.MAX_BYTES * 2
		socket.max_queued_packets = 64
		socket.heartbeat_interval = 10.0
		if socket.accept_stream(transport) == OK:
			_peers[_next_peer] = {"socket": socket, "session": 0,
				"opened": now, "window": now, "count": 0}
			_next_peer += 1
	for id: int in _peers.keys():
		if not _peers.has(id):
			continue
		var peer: Dictionary = _peers[id]
		var socket: WebSocketPeer = peer.socket
		socket.poll()
		if socket.get_ready_state() == WebSocketPeer.STATE_CLOSED \
			or (peer.session == 0 and now - int(peer.opened) > 5000):
			_drop(id)
			continue
		if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
			continue
		if socket.get_selected_protocol() != SgProtocol.SUBPROTOCOL:
			_drop(id)
			continue
		for i in 16:
			if not _peers.has(id) or socket.get_available_packet_count() == 0:
				break
			var bytes := socket.get_packet()
			if now - int(peer.window) >= 1000:
				peer.window = now
				peer.count = 0
			peer.count += 1
			var message := SgProtocol.decode(bytes) if socket.was_string_packet() else {}
			if message.is_empty() or peer.count > 64:
				_drop(id)
				break
			_receive(id, message)


func _drop(id: int) -> void:
	if not _peers.has(id):
		return
	var peer: Dictionary = _peers[id]
	peer.socket.close(-1)
	_peers.erase(id)
	var session: Dictionary = _sessions.get(peer.session, {})
	if not session.is_empty() and session.peer == id:
		session.peer = 0
		_bump_room(session.room)
		_publish()


func _send(id: int, message: Dictionary) -> void:
	if not _peers.has(id):
		return
	var socket: WebSocketPeer = _peers[id].socket
	var text := SgProtocol.encode(message)
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	if text.length() > SgProtocol.MAX_BYTES or socket.get_current_outbound_buffered_amount() > SgProtocol.MAX_BYTES:
		socket.close(-1)
		return
	if socket.send_text(text) != OK:
		socket.close(-1)


func _receive(id: int, message: Dictionary) -> void:
	var sid := int(_peers[id].session)
	if sid == 0:
		if message.type != "hello" or message.access != access_code:
			_drop(id)
			return
		var resume := String(message.resume)
		if not resume.is_empty():
			sid = int(_tokens.get(resume.sha256_text(), 0))
			if sid == 0:
				_drop(id)
				return
		else:
			if _sessions.size() >= MAX_SESSIONS:
				_drop(id)
				return
			var secret := Crypto.new().generate_random_bytes(32)
			if secret.size() != 32:
				_drop(id)
				return
			resume = secret.hex_encode()
			sid = _next_session
			_next_session += 1
			_sessions[sid] = {"peer": 0, "room": "", "seq": 0, "acks": {},
				"nickname": message.nickname}
			_tokens[resume.sha256_text()] = sid
		var session: Dictionary = _sessions[sid]
		var previous := int(session.peer)
		# Assign replacement first; dropping the old socket cannot detach the new one.
		session.peer = id
		_peers[id].session = sid
		if previous != 0 and _peers.has(previous):
			_peers[previous].session = 0
			_peers[previous].opened = Time.get_ticks_msec()
			_peers[previous].socket.close(4001, "Session moved")
		_bump_room(session.room)
		_send(id, {"type": "welcome", "v": SgProtocol.VERSION,
			"resume": resume, "seq": session.seq, "guest": _guest_name(sid)})
		_publish()
		return
	if message.type != "command":
		_drop(id)
		return
	var session: Dictionary = _sessions[sid]
	var seq := int(message.seq)
	var encoded := JSON.stringify(message)
	var ack: Dictionary
	if seq <= int(session.seq):
		var previous: Dictionary = session.acks.get(seq, {})
		if previous.is_empty() or previous.payload != encoded:
			_send(id, {"type": "fatal", "error": "Expired or conflicting command."})
			_peers[id].socket.close(-1)
			return
		_send(id, previous.ack)
		_send(id, _state(sid))
		return
	if seq != int(session.seq) + 1:
		_drop(id)
		return
	var error := "The room changed. Please try again."
	if message.room == session.room:
		error = _command(sid, message.action, int(message.revision))
	ack = {"type": "ack", "seq": seq, "ok": error.is_empty(), "error": error}
	session.seq = seq
	session.acks[seq] = {"payload": encoded, "ack": ack}
	session.acks.erase(seq - ACK_WINDOW)
	_send(id, ack)
	_publish()


func _bump_room(room_id: String) -> void:
	if _rooms.has(room_id):
		_rooms[room_id].revision += 1


func _connected(sid: int) -> bool:
	return sid != 0 and _sessions.has(sid) and int(_sessions[sid].peer) != 0


func _command(sid: int, action: Dictionary, revision: int) -> String:
	var session: Dictionary = _sessions[sid]
	var op := String(action.op)
	var room: Dictionary = _rooms.get(session.room, {})
	if not room.is_empty() and revision != int(room.revision):
		return "The room changed. Please try again."
	if op == "host":
		if not room.is_empty() or _rooms.size() >= MAX_ROOMS:
			return "Leave your room first, or wait for room space."
		var room_id := "r%d" % _next_room
		_next_room += 1
		_rooms[room_id] = {"id": room_id, "name": action.name.strip_edges(),
			"seats": [sid, 0], "ready": [false, false], "revision": 1, "match": null,
			"decks": [{}, {}]}
		session.room = room_id
		return ""
	if op == "join":
		if not room.is_empty() or not _rooms.has(action.room):
			return "Room unavailable."
		var target: Dictionary = _rooms[action.room]
		if target.seats[1] != 0 or target.match != null or not _connected(target.seats[0]):
			return "Room unavailable."
		target.seats[1] = sid
		target.revision += 1
		session.room = action.room
		return ""
	if room.is_empty():
		return "Join a room first."
	var seat := int(room.seats.find(sid))
	if seat < 0:
		return "Seat unavailable."
	if op == "leave":
		if room.match != null and not room.match.game.game_over:
			return "Concede before leaving a running duel."
		session.room = ""
		if room.match == null and seat == 0:
			for member: int in room.seats:
				if member != 0:
					_sessions[member].room = ""
			_rooms.erase(room.id)
		else:
			room.seats[seat] = 0
			room.ready[seat] = false
			room.decks[seat] = {}
			room.revision += 1
			if room.seats == [0, 0]:
				_rooms.erase(room.id)
		return ""
	if op == "deck":
		if room.match != null:
			return "The duel has started."
		var error := SgDeckCatalog.validate(action.cards, action.sideboard)
		if not error.is_empty(): return error
		room.decks[seat] = {"name": action.name, "cards": action.cards.duplicate(), "sideboard": action.sideboard.duplicate()}
		room.ready = [false, false]
		room.revision += 1
		return ""
	if op == "ready":
		if room.match != null:
			return "The duel has started."
		room.ready[seat] = action.value
		if room.ready == [true, true] and _connected(room.seats[0]) and _connected(room.seats[1]):
			room.match = SgPracticeMatch.new(-1, room.decks, [_guest_name(room.seats[0]), _guest_name(room.seats[1])])
		room.revision += 1
		return ""
	if room.match == null:
		return "Both players must be ready."
	if op != "concede" and (not _connected(room.seats[0]) or not _connected(room.seats[1])):
		return "Waiting for the other player to reconnect."
	var error: String = room.match.act(seat, action)
	if error.is_empty():
		room.revision += 1
	return error


func _guest_name(sid: int) -> String:
	if not _sessions.has(sid):
		return "Empty seat"
	var nickname: String = _sessions[sid].nickname
	# Display only. Seat authority always comes from the secret session capability.
	return "Guest %d" % sid if nickname.is_empty() else "%s (Guest %d)" % [nickname, sid]


func _state(sid: int) -> Dictionary:
	var rooms: Array = []
	for room: Dictionary in _rooms.values():
		rooms.append({"id": room.id, "name": room.name, "host": _guest_name(room.seats[0]),
			"open": room.match == null and room.seats[1] == 0 and _connected(room.seats[0])})
	var own: Dictionary = _rooms.get(_sessions[sid].room, {})
	var view: Dictionary = {}
	if not own.is_empty():
		var seat := int(own.seats.find(sid))
		view = {"id": own.id, "name": own.name, "seat": seat,
			"names": [_guest_name(own.seats[0]), _guest_name(own.seats[1])],
			"revision": own.revision, "ready": own.ready.duplicate(),
			"connected": [_connected(own.seats[0]), _connected(own.seats[1])],
			"deck_names": [own.decks[0].get("name", "Forest practice"), own.decks[1].get("name", "Forest practice")],
			"deck": own.decks[seat].duplicate(true),
			"game": {} if own.match == null else own.match.view(seat)}
	return {"type": "state", "rooms": rooms, "room": view}


func _publish() -> void:
	for sid: int in _sessions:
		if _connected(sid):
			_send(_sessions[sid].peer, _state(sid))
