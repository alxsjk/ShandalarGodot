class_name SgLocalClient
extends Node
## [QoL] Data-only client. One outstanding command; memory-only seat resumption.
## Plain WS only on loopback; native LAN connections require a pinned TLS invite.

signal changed
signal refused(reason: String)
var state: Dictionary = {"rooms": [], "room": {}}
var status := "Not connected"
var online := false
var guest := ""
var _socket: WebSocketPeer
var _port := 0
var _access := ""
var _resume := ""
var _nickname := ""
var _seq := 1
var _pending: Dictionary = {}
var _hello_sent := false
var _wanted := false
var _retry_at := 0
var _backoff := 500
var _opened := 0
var _sent_at := 0
var _address := "127.0.0.1"
var _tls_options: TLSOptions


func connect_invitation(invitation: String, temporary_name := "") -> Error:
	if OS.has_feature("web"):
		return ERR_UNAVAILABLE
	var data := SgLanInvite.parse(invitation.strip_edges())
	var clean_name := temporary_name.strip_edges()
	if data.is_empty() or not SgProtocol.nickname(clean_name):
		return ERR_INVALID_PARAMETER
	var cert := SgLanInvite.certificate(data)
	if cert == null:
		return ERR_INVALID_PARAMETER
	forget()
	_address = data.address
	_port = int(data.port)
	_access = data.access
	_nickname = clean_name
	_tls_options = TLSOptions.client(cert, SgLanInvite.COMMON_NAME)
	_wanted = true
	return _connect()


func connect_local(local_port: int, code: String, temporary_name := "") -> Error:
	var clean_name := temporary_name.strip_edges()
	if local_port < 1 or local_port > 65535 or not SgProtocol.token(code) \
		or not SgProtocol.nickname(clean_name):
		return ERR_INVALID_PARAMETER
	forget()
	_port = local_port
	_access = code
	_nickname = clean_name
	_wanted = true
	return _connect()


func _connect() -> Error:
	_socket = WebSocketPeer.new()
	_socket.supported_protocols = PackedStringArray([SgProtocol.SUBPROTOCOL])
	_socket.inbound_buffer_size = SgProtocol.MAX_BYTES * 2
	_socket.outbound_buffer_size = 65536
	_socket.max_queued_packets = 64
	_socket.heartbeat_interval = 10.0
	_hello_sent = false
	_opened = Time.get_ticks_msec()
	status = "Connecting..."
	changed.emit()
	var scheme := "wss" if _tls_options != null else "ws"
	return _socket.connect_to_url("%s://%s:%d" % [scheme, _address, _port], _tls_options)


func forget() -> void:
	_wanted = false
	if _socket != null:
		_socket.close(-1)
	_socket = null
	_access = ""
	_resume = ""
	_nickname = ""
	_address = "127.0.0.1"
	_port = 0
	_tls_options = null
	guest = ""
	_pending = {}
	_seq = 1
	online = false
	_backoff = 500
	state = {"rooms": [], "room": {}}
	status = "Not connected"


func _exit_tree() -> void:
	forget()


func busy() -> bool:
	return not _pending.is_empty()


func has_session() -> bool:
	return not _resume.is_empty()


func reconnect() -> void:
	if _port == 0 or not has_session():
		return
	if _socket != null:
		_socket.close(-1)
	online = false
	_wanted = true
	_retry_at = 0
	_connect()


func command(action: Dictionary) -> bool:
	if not online or busy() or _socket == null or _socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return false
	var message := {"v": SgProtocol.VERSION, "type": "command", "seq": _seq,
		"room": String(state.room.get("id", "")),
		"revision": int(state.room.get("revision", 0)), "action": action.duplicate(true)}
	if not SgProtocol.valid(message):
		return false
	_pending = message
	_seq += 1
	_send_pending()
	changed.emit()
	return true


func _send_pending() -> void:
	if not _pending.is_empty() and _socket != null \
		and _socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_socket.send_text(SgProtocol.encode(_pending))
		_sent_at = Time.get_ticks_msec()


func _process(_delta: float) -> void:
	poll()


func poll() -> void:
	if not _wanted or _socket == null:
		return
	var now := Time.get_ticks_msec()
	_socket.poll()
	var connection := _socket.get_ready_state()
	if connection == WebSocketPeer.STATE_CLOSED:
		if _socket.get_close_code() == 4001:
			_wanted = false
			online = false
			status = "This seat was resumed in another connection."
			changed.emit()
			return
		if online:
			online = false
			status = "Connection lost; reconnecting..."
			_retry_at = now + _backoff
			changed.emit()
		if now >= _retry_at:
			_retry_at = now + _backoff
			_backoff = mini(_backoff * 2, 8000)
			_connect()
		return
	if not online and now - _opened > 5000:
		_socket.close(-1)
		status = "Cannot join. Check the host, invitation, firewall and computer clocks."
		changed.emit()
		return
	if connection != WebSocketPeer.STATE_OPEN:
		return
	if not _hello_sent:
		_socket.send_text(JSON.stringify({"v": SgProtocol.VERSION,
			"type": "hello", "access": _access, "resume": _resume, "nickname": _nickname}))
		_hello_sent = true
	for i in 32:
		if _socket.get_available_packet_count() == 0:
			break
		var packet := _socket.get_packet()
		var message := SgProtocol.decode_payload(packet) if _socket.was_string_packet() else {}
		if not SgViewProtocol.valid(message) or (not online and message.get("type") != "welcome") \
			or (online and message.get("type") == "welcome"):
			_wanted = false
			online = false
			status = "Host sent an invalid response. Connection stopped."
			_socket.close(-1)
			changed.emit()
			return
		match message.get("type", ""):
			"welcome":
				if message.get("v") != SgProtocol.VERSION or not SgProtocol.token(message.get("resume")):
					_socket.close(-1)
					return
				_resume = message.resume
				guest = message.guest
				_seq = maxi(_seq, int(message.seq) + 1)
				online = true
				_backoff = 500
				status = "Connected - %s playtest (unrated)" % ("encrypted LAN" if _tls_options != null else "local")
				_send_pending()
			"state":
				if not message.get("rooms") is Array or not message.get("room") is Dictionary:
					_socket.close(-1)
					return
				state = message
			"ack":
				if not _pending.is_empty() and message.get("seq") == _pending.seq:
					_pending = {}
					if not bool(message.get("ok", false)):
						refused.emit(String(message.get("error", "Command refused.")))
			"fatal":
				_wanted = false
				online = false
				status = "Session cannot continue. Start a new local session."
				_socket.close(-1)
			_: _socket.close(-1)
		changed.emit()
	if online and busy() and now - _sent_at > 2000:
		_send_pending()
