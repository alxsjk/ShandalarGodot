extends GutTest
## Real loopback sockets around the room's session state: readiness that
## outlived a disconnection, and the duel that owes both of them.

var server: SgLocalServer
var a: SgLocalClient
var b: SgLocalClient


func before_each() -> void:
	server = SgLocalServer.new()
	add_child_autofree(server)
	assert_eq(server.start_local(0), OK)
	a = SgLocalClient.new()
	b = SgLocalClient.new()
	add_child_autofree(a)
	add_child_autofree(b)


func after_each() -> void:
	a.forget()
	b.forget()
	server.stop()


func _until(predicate: Callable, frames := 400) -> bool:
	for i in frames:
		if predicate.call():
			return true
		await get_tree().process_frame
	assert_true(false, "network operation did not finish within its frame budget")
	return false


func _pair() -> void:
	assert_eq(a.connect_local(server.port, server.access_code), OK)
	assert_eq(b.connect_local(server.port, server.access_code), OK)
	await _until(func() -> bool: return a.online and b.online)


func _act(client: SgLocalClient, action: Dictionary) -> bool:
	var accepted := client.command(action)
	assert_true(accepted, "command accepted by client: " + str(action))
	if not accepted:
		return false
	if not await _until(func() -> bool: return not client.busy()):
		return false
	for i in 3:
		await get_tree().process_frame
	return true


func test_a_returning_seat_starts_the_duel_both_players_already_readied() -> void:
	await _pair()
	await _act(a, {"op": "host", "name": "Waiting room", "decks": "own", "deck": {}})
	await _act(b, {"op": "join", "room": a.state.room.id})
	var room_id: String = a.state.room.id
	await _act(b, {"op": "ready", "value": true})
	b.set_process(false)
	b._socket.close(-1)
	await _until(func() -> bool: return a.state.room.connected == [true, false])
	await _act(a, {"op": "ready", "value": true})
	assert_eq(server._rooms[room_id].ready, [true, true], "readiness is kept for the absent seat")
	assert_null(server._rooms[room_id].match, "no duel is dealt to an empty chair")
	b.set_process(true)
	b.reconnect()
	await _until(func() -> bool: return b.online)
	await _until(func() -> bool: return not b.state.room.get("game", {}).is_empty())
	assert_not_null(server._rooms[room_id].match, "the returning seat completes the pair")
	assert_eq(b.state.room.connected, [true, true])
	assert_eq(a.state.room.game.hand.size(), 7)
	assert_eq(b.state.room.game.hand.size(), 7)
	assert_eq(b.state.room.game.mode, "opening")
	var refusals: Array = []
	a.refused.connect(func(reason: String) -> void: refusals.append(reason))
	await _act(a, {"op": "ready", "value": false})
	assert_eq(refusals, ["The duel has started."], "readiness cannot be taken back afterwards")


func test_a_returning_seat_leaves_a_half_readied_room_waiting() -> void:
	await _pair()
	await _act(a, {"op": "host", "name": "Waiting room", "decks": "own", "deck": {}})
	await _act(b, {"op": "join", "room": a.state.room.id})
	var room_id: String = a.state.room.id
	await _act(a, {"op": "ready", "value": true})
	b.set_process(false)
	b._socket.close(-1)
	await _until(func() -> bool: return a.state.room.connected == [true, false])
	b.set_process(true)
	b.reconnect()
	await _until(func() -> bool: return b.online)
	for i in 6:
		await get_tree().process_frame
	assert_eq(server._rooms[room_id].ready, [true, false])
	assert_null(server._rooms[room_id].match, "one Ready mark is still only one")


func test_a_closed_room_leaves_no_cached_view_behind() -> void:
	await _pair()
	await _act(a, {"op": "host", "name": "Short duel", "decks": "own", "deck": {}})
	await _act(b, {"op": "join", "room": a.state.room.id})
	var room_id: String = a.state.room.id
	await _act(a, {"op": "ready", "value": true})
	await _act(b, {"op": "ready", "value": true})
	await _until(func() -> bool: return not a.state.room.game.is_empty())
	assert_eq(server._view_cache.keys(), [room_id], "the duel's views are memoized")
	await _act(a, {"op": "concede"})
	await _act(b, {"op": "leave"})
	await _act(a, {"op": "leave"})
	assert_true(server._rooms.is_empty())
	assert_true(server._view_cache.is_empty(), "no cached view outlives its room")
