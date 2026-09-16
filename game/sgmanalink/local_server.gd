class_name SgLocalServer
extends Node
## [QoL] Volatile loopback/LAN referee. Not a public authentication service.
## Access and resume capabilities live in memory, never game settings or duel logs.
## LAN binds one private IPv4 address, uses TLS, and never opens router ports.

const MAX_CONNECTIONS := SgTournament.MAX_PLAYERS + 4
const MAX_SESSIONS := SgTournament.MAX_PLAYERS * 2 + 8
const MAX_ROOMS := SgTournament.MAX_PLAYERS / 2
const ACK_WINDOW := 128
const RECONNECT_GRACE_MS := 300000
const LOBBY_GRACE_MS := 30000
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
var _view_cache: Dictionary = {}
var _pending_publish: Dictionary = {}
var _flush_queued := false
var tournament: SgTournamentHost
var _bot_due: Dictionary = {}
var _bot_cursor := 0
# Test-only pacing override; never accepted from a network command.
var bot_pace_override := -1


## Local organiser entry point, deliberately not a remote command. A visitor
## knowing the shared invitation does not acquire organiser authority.
func open_tournament(options: Dictionary, resume_code: String, folder: String, restore_path := "") -> String:
	var sid := int(_tokens.get(resume_code.sha256_text(), 0))
	if not _connected(sid): return "Connect the organiser to this host first."
	if not _rooms.is_empty() or (tournament != null and tournament.event.phase in ["registration", "running"]):
		return "Finish or cancel the existing tables and tournament first."
	var candidate := SgTournament.new()
	var error := candidate.configure(options) if restore_path.is_empty() \
		else candidate.restore(SgTournamentStore.read_checkpoint(restore_path))
	if not error.is_empty(): return error
	var bot_seats := 0
	for player: Dictionary in candidate.entrants:
		if player.has("bot") and not player.withdrawn: bot_seats += 1
	if _sessions.size() + bot_seats > MAX_SESSIONS:
		return "Not enough free host seats to restore every computer player. Close unused guest connections and try again."
	if SgTournamentStore.save(candidate, folder) != OK: return "Cannot save tournament progress. Check the tournaments folder."
	if tournament != null:
		remove_child(tournament)
		tournament.queue_free()
	tournament = SgTournamentHost.new()
	tournament.event = candidate
	tournament.organiser = sid
	tournament.folder = folder
	add_child(tournament)
	tournament.restore_bots()
	_publish()
	return ""


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
	CardPacks.lock_catalogue(self)
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
	CardPacks.lock_catalogue(self)
	return OK


func stop() -> void:
	CardPacks.unlock_catalogue(self)
	_listener.stop()
	if tournament != null:
		remove_child(tournament)
		tournament.queue_free()
		tournament = null
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
	_view_cache.clear()
	_pending_publish.clear()
	_bot_due.clear()
	_flush_queued = false
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
	_expire_disconnected(now)
	if discovery != null:
		var available := 0
		discovery.update_tournament("" if tournament == null else String(tournament.event.config.name))
		if tournament != null and tournament.event.phase == "registration": available += 1
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
		if peer.has("reject_until"):
			if now >= int(peer.reject_until): _drop(id)
			continue
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
			if not _peers.has(id) or _peers[id].has("reject_until") or socket.get_available_packet_count() == 0:
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
	_poll_bots(now)
	_flush_publish()


func _drop(id: int) -> void:
	if not _peers.has(id):
		return
	var peer: Dictionary = _peers[id]
	peer.socket.close(-1)
	_peers.erase(id)
	var session: Dictionary = _sessions.get(peer.session, {})
	if not session.is_empty() and session.peer == id:
		session.peer = 0
		session.disconnected_at = Time.get_ticks_msec()
		_bump_room(session.room)
		_publish(session.room, 0, true)


func _reject(id: int, reason: String) -> void:
	_send(id, {"type": "fatal", "error": reason})
	# Keep the transport alive long enough for the peer to consume the reason.
	if _peers.has(id): _peers[id].reject_until = Time.get_ticks_msec() + 1000


func _expire_disconnected(now: int) -> void:
	for sid in _sessions.keys():
		if _is_bot(sid): continue
		if tournament != null and tournament.holds(sid): continue
		var session: Dictionary = _sessions[sid]
		var grace := LOBBY_GRACE_MS if session.room.is_empty() else RECONNECT_GRACE_MS
		if session.peer == 0 and now - int(session.disconnected_at) >= grace: _abandon(sid)


func _abandon(sid: int) -> void:
	if not _sessions.has(sid): return
	var session: Dictionary = _sessions[sid]
	var room_id: String = session.room
	var room: Dictionary = _rooms.get(room_id, {})
	if tournament != null and tournament.member(sid) != 0:
		tournament.departed(sid)
		room = {}
	if not room.is_empty():
		var seat: int = room.seats.find(sid)
		if seat >= 0:
			if room.match != null and not room.match.game.game_over: room.match.game.concede(seat)
			room.seats[seat] = 0
			room.ready = [false, false]
			room.decks[seat] = {}
			room.revision += 1
			if room.seats == [0, 0] or (room.match == null and seat == 0):
				for member in room.seats:
					if _sessions.has(member): _sessions[member].room = ""
				_rooms.erase(room_id)
	var peer := int(session.peer)
	_sessions.erase(sid)
	_tokens.erase(session.token_hash)
	_drop(peer)
	_publish(room_id, 0, true)


func _send(id: int, message: Dictionary) -> void:
	if not _peers.has(id):
		return
	var socket: WebSocketPeer = _peers[id].socket
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	var text := SgProtocol.encode(message)
	if text.length() > SgProtocol.MAX_BYTES or socket.get_current_outbound_buffered_amount() > SgProtocol.MAX_BYTES:
		socket.close(-1)
		return
	if socket.send_text(text) != OK:
		socket.close(-1)


func _receive(id: int, message: Dictionary) -> void:
	var sid := int(_peers[id].session)
	if sid == 0:
		if message.type != "hello" or message.access != access_code:
			_reject(id, "Invalid invitation. Ask the host for a current invitation.")
			return
		if message.build != SgCompatibility.fingerprint():
			_reject(id, "Incompatible builds or card catalogue. Both players must use the same game build and enabled card packs.")
			return
		var resume := String(message.resume)
		if not resume.is_empty():
			sid = int(_tokens.get(resume.sha256_text(), 0))
			if sid == 0:
				_reject(id, "This temporary seat has expired. Disconnect and join with the current invitation.")
				return
		else:
			# Reclaim only disconnected, roomless guests under capacity pressure.
			if _sessions.size() >= MAX_SESSIONS:
				for candidate in _sessions.keys():
					if tournament != null and tournament.holds(candidate): continue
					if not _connected(candidate) and _sessions[candidate].room.is_empty():
						_abandon(candidate)
						break
			if _sessions.size() >= MAX_SESSIONS:
				_reject(id, "Host is full. Wait for a seat to become available, then reconnect.")
				return
			var secret := Crypto.new().generate_random_bytes(32)
			if secret.size() != 32:
				_drop(id)
				return
			resume = secret.hex_encode()
			sid = _next_session
			_next_session += 1
			_sessions[sid] = {"peer": 0, "room": "", "seq": 0, "acks": {},
				"nickname": message.nickname, "disconnected_at": 0, "token_hash": resume.sha256_text()}
			_tokens[resume.sha256_text()] = sid
		var session: Dictionary = _sessions[sid]
		var previous := int(session.peer)
		# Assign replacement first; dropping the old socket cannot detach the new one.
		session.peer = id
		session.disconnected_at = 0
		_peers[id].session = sid
		if previous != 0 and _peers.has(previous):
			_peers[previous].session = 0
			_peers[previous].opened = Time.get_ticks_msec()
			_peers[previous].socket.close(4001, "Session moved")
		_bump_room(session.room)
		_send(id, {"type": "welcome", "v": SgProtocol.VERSION,
			"resume": resume, "seq": session.seq, "guest": _guest_name(sid), "build": SgCompatibility.fingerprint()})
		_publish(session.room, sid, true)
		return
	if message.type == "abandon":
		_abandon(sid)
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
			_reject(id, "Expired or conflicting command. Disconnect and start a new session.")
			return
		_send(id, previous.ack)
		_publish("", sid, false)
		return
	if seq != int(session.seq) + 1:
		_drop(id)
		return
	var error := "The room changed. Please try again."
	var old_room: String = session.room
	var old_revision := int(_rooms.get(old_room, {}).get("revision", -1))
	if message.room == session.room:
		error = _command(sid, message.action, int(message.revision))
	ack = {"type": "ack", "seq": seq, "ok": error.is_empty(), "error": error}
	session.seq = seq
	session.acks[seq] = {"payload": encoded, "ack": ack}
	session.acks.erase(seq - ACK_WINDOW)
	_send(id, ack)
	var current_room: String = session.room
	var changed := current_room != old_room or int(_rooms.get(current_room, {}).get("revision", -1)) != old_revision
	if current_room != old_room and not old_room.is_empty(): _publish(old_room, 0, true)
	_publish(current_room if changed else "", sid, action_changes_listings(message.action.op) and changed)


func action_changes_listings(op: String) -> bool:
	return op in ["host", "join", "leave", "ready", "remove_guest", "concede", "add_bot", "remove_bot"]


func _bump_room(room_id: String) -> void:
	if _rooms.has(room_id):
		_rooms[room_id].revision += 1


func _connected(sid: int) -> bool:
	return sid != 0 and _sessions.has(sid) and (_is_bot(sid) or int(_sessions[sid].peer) != 0)


func _is_bot(sid: int) -> bool:
	return _sessions.has(sid) and _sessions[sid].has("bot")


func _new_bot(options: Dictionary, nickname: String) -> int:
	if not SgBotPlayer.valid(options) or _sessions.size() >= MAX_SESSIONS: return 0
	var sid := _next_session
	_next_session += 1
	# No resume token or socket: a human cannot claim a computer seat.
	_sessions[sid] = {"peer": 0, "room": "", "seq": 0, "acks": {}, "nickname": nickname,
		"disconnected_at": 0, "token_hash": "", "bot": options.duplicate(true)}
	return sid


func _attach_bots(room: Dictionary) -> void:
	for seat in 2:
		if _is_bot(room.seats[seat]): room.match.set_bot(seat, _sessions[room.seats[seat]].bot)


func _poll_bots(now: int) -> void:
	# One decision per table per poll, with round-robin fairness and a soft
	# 12ms frame budget. A single bounded Wizard decision is not preemptible.
	if tournament != null:
		if not tournament.save_error.is_empty(): return
		tournament.prepare_bots()
		# Automatic return/readiness can itself fail to save this frame.
		if not tournament.save_error.is_empty(): return
	var room_ids := _rooms.keys()
	var started := Time.get_ticks_msec()
	for offset in room_ids.size():
		var index := (_bot_cursor + offset) % room_ids.size()
		var room: Dictionary = _rooms.get(room_ids[index], {})
		if room.is_empty() or room.match == null or room.match.game.game_over: continue
		if not _connected(room.seats[0]) or not _connected(room.seats[1]): continue
		var match_game: SgPracticeMatch = room.match
		var actor := int(match_game.decision_state().actor)
		if not match_game.bots.has(actor) or now < int(_bot_due.get(room.id, 0)): continue
		var pace := int(match_game.bot_options[actor].pace_ms) if bot_pace_override < 0 else bot_pace_override
		_bot_due[room.id] = now + pace
		SgBotPlayer.step(match_game, match_game.bots[actor])
		room.revision += 1
		if tournament != null: tournament.collect_result(room)
		_publish(room.id, 0, match_game.game.game_over)
		if tournament != null and not tournament.save_error.is_empty(): break
		if Time.get_ticks_msec() - started >= 12:
			_bot_cursor = index + 1
			break
	# Human departure must not leave a bot-only ordinary room or a session
	# occupying capacity forever. Tournament bots remain registered instead.
	for room_id in _rooms.keys():
		var room: Dictionary = _rooms[room_id]
		if room.has("t_pair"): continue
		if room.seats.all(func(sid: int) -> bool: return sid == 0 or _is_bot(sid)):
			for sid: int in room.seats:
				if _is_bot(sid): _sessions[sid].room = ""
			_rooms.erase(room_id)
			_view_cache.erase(room_id)
	for sid in _sessions.keys():
		if _is_bot(sid) and _sessions[sid].room.is_empty() and (tournament == null or not tournament.holds(sid)):
			_sessions.erase(sid)
	for room_id in _bot_due.keys():
		if not _rooms.has(room_id): _bot_due.erase(room_id)


func _command(sid: int, action: Dictionary, revision: int) -> String:
	var session: Dictionary = _sessions[sid]
	var op := String(action.op)
	var room: Dictionary = _rooms.get(session.room, {})
	if op.begins_with("t_"):
		return "No tournament is hosted here." if tournament == null else tournament.command(sid, action, revision)
	if tournament != null:
		if op in ["host", "join", "deck", "ready", "remove_guest", "leave", "add_bot", "remove_bot"]:
			return "Use the Tournament Hall while this host runs a tournament."
		if not tournament.save_error.is_empty(): return tournament.save_error
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
		target.ready = [false, false]
		target.revision += 1
		session.room = action.room
		return ""
	if room.is_empty():
		return "Join a room first."
	var seat := int(room.seats.find(sid))
	if seat < 0:
		return "Seat unavailable."
	if op in ["add_bot", "remove_bot"]:
		if seat != 0 or room.match != null: return "Only the room host can change computer seats before play."
		if op == "remove_bot":
			if not _is_bot(room.seats[1]): return "No computer seat to remove."
			_sessions.erase(room.seats[1])
			room.seats[1] = 0
			room.decks[1] = {}
			room.ready = [false, false]
		else:
			if room.seats[1] != 0: return "The opponent's seat is occupied."
			if not SgBotPlayer.valid(action.bot) or not SgTournament.valid_deck(action.deck): return "Choose a computer level and valid deck."
			var bot_sid := _new_bot(action.bot, SgBotPlayer.label(action.bot) + " bot")
			if bot_sid == 0: return "Host is full."
			room.seats[1] = bot_sid
			_sessions[bot_sid].room = room.id
			room.decks[1] = action.deck.duplicate(true)
			room.ready = [false, true]
		room.revision += 1
		return ""
	if op == "remove_guest":
		if seat != 0 or room.match != null or room.seats[1] == 0 or _connected(room.seats[1]):
			return "Only the room host can remove a disconnected guest before the duel starts."
		_abandon(int(room.seats[1]))
		return ""
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
			room.ready = [false, false]
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
		room.ready = [_is_bot(room.seats[0]), _is_bot(room.seats[1])]
		room.revision += 1
		return ""
	if op == "ready":
		if room.match != null:
			return "The duel has started."
		room.ready[seat] = action.value
		if room.ready == [true, true] and _connected(room.seats[0]) and _connected(room.seats[1]):
			room.match = _create_match(room.decks, [_guest_name(room.seats[0]), _guest_name(room.seats[1])])
			_attach_bots(room)
		room.revision += 1
		return ""
	if room.match == null:
		return "Both players must be ready."
	if op != "concede" and (not _connected(room.seats[0]) or not _connected(room.seats[1])):
		return "Waiting for the other player to reconnect."
	var generation: int = room.match.state_generation
	var draft: Dictionary = room.match.actions.draft.duplicate()
	var error: String = room.match.act(seat, action)
	# A refused cast may still change its private target-count/payment draft;
	# multi-step payments can also change rules state before a later refusal.
	if error.is_empty() or generation != room.match.state_generation or draft != room.match.actions.draft:
		room.revision += 1
	if tournament != null:
		var storage_error := tournament.collect_result(room)
		if not storage_error.is_empty(): return storage_error
	return error


func _create_match(decks: Array, names: Array) -> SgPracticeMatch:
	# The referee chooses its seed. Tests may override this factory on their
	# own server; no wire command can choose or retrieve a live game's seed.
	return SgPracticeMatch.new(-1, decks, names)


func _guest_name(sid: int) -> String:
	if not _sessions.has(sid):
		return "Empty seat"
	var nickname: String = _sessions[sid].nickname
	if _is_bot(sid): return nickname
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
			"game": _room_game(own, seat)}
		if _is_bot(own.seats[0]) or _is_bot(own.seats[1]):
			view.bots = []
			for sid_value: int in own.seats:
				view.bots.append(_sessions[sid_value].bot.duplicate(true) if _is_bot(sid_value) else {})
		if own.has("t_pair") and tournament != null:
			view.tournament = tournament.context(own)
			view.names = []
			for pid: int in tournament.event.pairing(own.t_pair).players: view.names.append(tournament.event.entrant(pid).name)
	var result := {"type": "state", "rooms": rooms, "room": view}
	if tournament != null: result.tournament = tournament.view(sid)
	return result


func _room_game(room: Dictionary, seat: int) -> Dictionary:
	if room.match == null: return {}
	var cached: Dictionary = _view_cache.get(room.id, {})
	if cached.is_empty() or cached.revision != room.revision or cached.match != room.match:
		cached = {"revision": room.revision, "match": room.match, "views": {}}
		_view_cache[room.id] = cached
	if not cached.views.has(seat): cached.views[seat] = room.match.view(seat)
	return cached.views[seat]


func _publish(changed_room := "*", requester := 0, listings := true) -> void:
	# A no-argument call is an explicit refresh (also used by test fixtures).
	# An explicitly empty room only updates listings; it cannot dirty all duels.
	var refresh_all := changed_room == "*"
	if refresh_all: _view_cache.clear()
	elif not changed_room.is_empty(): _view_cache.erase(changed_room)
	for sid: int in _sessions:
		if _connected(sid) and not _is_bot(sid):
			if refresh_all or sid == requester or (tournament != null and sid == tournament.organiser) \
				or (not changed_room.is_empty() and _sessions[sid].room == changed_room) or listings:
				_pending_publish[sid] = true
	if not _flush_queued:
		_flush_queued = true
		_flush_publish.call_deferred()


func _flush_publish() -> void:
	_flush_queued = false
	var pending := _pending_publish.keys()
	_pending_publish.clear()
	for sid in pending:
		if _connected(sid) and not _is_bot(sid): _send(_sessions[sid].peer, _state(sid))
