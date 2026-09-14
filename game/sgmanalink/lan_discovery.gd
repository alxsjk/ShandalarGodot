class_name SgLanDiscovery
extends Node
## [QoL] Explicit, bounded IPv4 LAN discovery. UDP announcements are UNTRUSTED.
## Broadcast queries + unicast replies; no accounts, directory or secret broadcast.
## Desktop only. Joining always uses a separately shared, certificate-pinned invite.

signal changed
const PORT := 17898
const MAX_PACKET := 768
const MAX_HOSTS := 64
const EXPIRES_MS := 7000
var hosts: Dictionary = {}
var scanning := false
var advertising := false
var status := ""
var _socket := PacketPeerUDP.new()
var _advert: Dictionary = {}
var _nonce := ""
var _next_query := 0
var _reply_window := 0
var _replies := 0


func scan() -> Error:
	if OS.has_feature("web") or advertising:
		return ERR_UNAVAILABLE
	stop()
	var error := _socket.bind(0, "0.0.0.0", 65536)
	if error != OK:
		return error
	_socket.set_broadcast_enabled(true)
	_nonce = Crypto.new().generate_random_bytes(32).hex_encode()
	scanning = true
	status = "Looking for LAN hosts..."
	query()
	return OK


func advertise(advert: Dictionary, discovery_port := PORT) -> Error:
	if OS.has_feature("web") or not valid_advert(advert):
		return ERR_INVALID_PARAMETER
	stop()
	var error := _socket.bind(discovery_port, "0.0.0.0", 65536)
	if error != OK:
		status = "LAN discovery port is busy; share the invitation to join directly."
		return error
	_advert = advert.duplicate(true)
	advertising = true
	return OK


func update_rooms(count: int) -> void:
	if advertising:
		_advert.rooms = clampi(count, 0, 8)


func stop() -> void:
	_socket.close()
	hosts.clear()
	scanning = false
	advertising = false
	_advert = {}
	_nonce = ""
	_next_query = 0
	_replies = 0
	_reply_window = 0


func _exit_tree() -> void:
	stop()


func query(destination := "255.255.255.255", discovery_port := PORT) -> void:
	if not scanning or (destination != "255.255.255.255" and not SgLanInvite.address(destination)):
		return
	var packet := JSON.stringify({"v": SgProtocol.VERSION, "type": "sg-lan-query", "nonce": _nonce})
	if _socket.set_dest_address(destination, discovery_port) == OK:
		_socket.put_packet(packet.to_ascii_buffer())
	_next_query = Time.get_ticks_msec() + 2000


static func valid_advert(data: Dictionary) -> bool:
	return SgProtocol.exact(data, ["address", "port", "name", "fingerprint", "rooms"]) \
		and SgLanInvite.address(data.get("address")) \
		and SgProtocol.integer(data.get("port"), 1, 65535) \
		and SgProtocol.short_text(data.get("name"), SgProtocol.NICKNAME_LIMIT) \
		and SgProtocol.token(data.get("fingerprint")) and SgProtocol.integer(data.get("rooms"), 0, 8)


func accept_reply(data: Dictionary, source: String, now: int) -> bool:
	if not scanning or not SgProtocol.exact(data, ["v", "type", "nonce", "host"]) \
		or data.get("v") != SgProtocol.VERSION or data.get("type") != "sg-lan-host" \
		or data.get("nonce") != _nonce or not SgLanInvite.address(source) \
		or not data.get("host") is Dictionary or not valid_advert(data.host):
		return false
	var advert: Dictionary = data.host
	# A discovery packet is never permission to contact a different IP.
	if advert.address != source:
		return false
	var key := "%s:%d" % [source, int(advert.port)]
	if not hosts.has(key) and hosts.size() >= MAX_HOSTS:
		return false
	var previous: Dictionary = hosts.get(key, {})
	var changed_data: bool = previous.get("host", {}) != advert
	hosts[key] = {"host": advert.duplicate(true), "seen": now}
	if changed_data:
		changed.emit()
	return true


func expire(now: int) -> void:
	var removed := false
	for key in hosts.keys():
		if now - int(hosts[key].seen) >= EXPIRES_MS:
			hosts.erase(key)
			removed = true
	if removed:
		changed.emit()


func _process(_delta: float) -> void:
	if not scanning and not advertising:
		return
	var now := Time.get_ticks_msec()
	if scanning:
		if now >= _next_query:
			query()
		expire(now)
	if now - _reply_window >= 1000:
		_reply_window = now
		_replies = 0
	for i in 32:
		if _socket.get_available_packet_count() == 0:
			break
		var bytes := _socket.get_packet()
		var source := _socket.get_packet_ip()
		var source_port := _socket.get_packet_port()
		if bytes.size() > MAX_PACKET or not SgLanInvite.address(source):
			continue
		var data := SgProtocol.decode_payload(bytes, 3)
		if scanning:
			accept_reply(data, source, now)
		elif advertising and _replies < 16 \
			and SgProtocol.exact(data, ["v", "type", "nonce"]) \
			and data.get("v") == SgProtocol.VERSION and data.get("type") == "sg-lan-query" \
			and SgProtocol.token(data.get("nonce")):
			_replies += 1
			var reply := {"v": SgProtocol.VERSION, "type": "sg-lan-host",
				"nonce": data.nonce, "host": _advert}
			# Reply from the queried port so stateful firewalls can associate it
			# with the outbound query. Routing chooses the source LAN adapter.
			if _socket.set_dest_address(source, source_port) == OK:
				_socket.put_packet(JSON.stringify(reply).to_ascii_buffer())
