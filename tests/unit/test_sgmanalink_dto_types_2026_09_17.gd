extends GameTest
## A field of the wrong TYPE is refused, not raised over. GDScript answers
## `5 != "command"` with an "Invalid operands" runtime error rather than
## with true, so a validator that compares an untrusted field before it has
## type-checked it stops mid-answer — and the run prints a script error for
## a packet whose whole purpose was to be refused quietly.


func _referee() -> SgPracticeMatch:
	var result := SgPracticeMatch.new(42)
	result.game = g
	result.view(0)
	result.view(1)
	return result


func _command(action: Dictionary) -> Dictionary:
	return {"v": SgProtocol.VERSION, "type": "command", "seq": 1, "room": "", "revision": 0, "action": action}


func test_a_wire_command_with_mistyped_text_is_refused_quietly() -> void:
	var message := _command({"op": "pass"})
	assert_true(SgProtocol.valid(message))
	for kind in [5, true, [], {}, null, 1.5]:
		var broken := message.duplicate(true)
		broken.type = kind
		assert_false(SgProtocol.valid(broken), "message type: " + str(kind))
	for room in [5, true, [], {}, null]:
		var broken := message.duplicate(true)
		broken.room = room
		assert_false(SgProtocol.valid(broken), "room name: " + str(room))
	var hello := {"v": SgProtocol.VERSION, "type": "hello", "access": "0".repeat(64),
		"resume": 7, "nickname": "Fox", "build": SgCompatibility.fingerprint(), "stamp": SgCompatibility.stamp()}
	assert_false(SgProtocol.valid(hello), "a numeric resume capability is not an empty one")


func test_a_discovery_packet_with_mistyped_fields_is_refused_quietly() -> void:
	var scanner := SgLanDiscovery.new()
	add_child_autofree(scanner)
	scanner.scanning = true
	scanner._nonce = "b".repeat(64)
	var advert := {"address": "192.168.0.5", "port": 17897, "name": "Forest Fox", "access": "invitation", "tables": [],
		"fingerprint": "a".repeat(64), "rooms": 1, "build": SgCompatibility.fingerprint(),
		"stamp": SgCompatibility.stamp()}
	var reply := {"v": SgProtocol.VERSION, "type": "sg-lan-host", "nonce": scanner._nonce, "host": advert}
	assert_true(scanner.accept_reply(reply, "192.168.0.5", 100))
	for field in ["v", "type", "nonce"]:
		for value in [5, "text", true, [], {}, null]:
			var broken := reply.duplicate(true)
			broken[field] = value
			assert_false(scanner.accept_reply(broken, "192.168.0.5", 100), "%s: %s" % [field, str(value)])
	assert_eq(scanner.hosts.size(), 1, "one honest listing survives every malformed neighbour")
	scanner.stop()


func test_a_host_snapshot_with_mistyped_fields_is_refused_quietly() -> void:
	var view := _referee().view(0)
	assert_true(SgViewProtocol.game(view))
	for seat in 2:
		for value in ["0", true, [], {}, null, 1.5]:
			var broken := view.duplicate(true)
			broken.players[seat].seat = value
			assert_false(SgViewProtocol.game(broken), "seat number: " + str(value))
	assert_false(SgViewProtocol.presentation({}))
	var blocks: Dictionary = view.presentation.duplicate(true)
	blocks.blocks = [["c1", 7]]
	assert_false(SgViewProtocol.presentation(blocks), "a numeric block destination")
	for kind in [4, true, [], null]:
		assert_false(SgViewProtocol.text_effects([{"kind": kind, "from": 1, "to": 2}]), "effect kind: " + str(kind))
	for kind in [4, true, [], {}, null]:
		assert_false(SgViewProtocol.valid({"type": kind}), "message kind: " + str(kind))
	assert_false(SgViewProtocol.valid({"type": "welcome", "v": "17", "resume": "a".repeat(64),
		"seq": 1, "guest": "Fox", "build": "b".repeat(64)}), "protocol version as text")


func test_a_saved_tournament_with_mistyped_fields_is_refused_quietly() -> void:
	var event := SgTournament.new()
	assert_eq(event.configure({"name": "Type check", "limit": 4, "wins": 1, "policy": "own", "decks": []}), "")
	var saved := event.checkpoint()
	assert_true(SgTournamentProtocol.checkpoint(saved))
	for value in ["1", true, [], null, 2]:
		var broken := saved.duplicate(true)
		broken.schema = value
		assert_false(SgTournamentProtocol.checkpoint(broken), "schema: " + str(value))
	for value in [1, true, [], null]:
		var broken := saved.duplicate(true)
		broken.build = value
		assert_false(SgTournamentProtocol.checkpoint(broken), "build stamp: " + str(value))
	assert_false(SgTournamentProtocol.rows([[{"id": "1", "players": [1, 2], "wins": [0, 0], "draws": 0,
		"game": 0, "status": "waiting", "winner": 0, "reason": ""}]], [1, 2], 1), "a pairing numbered with text")


func test_an_attachment_must_name_a_card_this_view_carries() -> void:
	var bears := put_battlefield(0, "Grizzly Bears")
	var aura := put_battlefield(0, "Holy Strength")
	g.attach_aura_from_anywhere(aura, bears, 0)
	var view := _referee().view(1)
	assert_true(SgViewProtocol.game(view))
	var faces: Array = view.players[0].battlefield
	var enchantment: Dictionary = {}
	for card in faces:
		if card.name == "Holy Strength":
			enchantment = card
	assert_false(enchantment.is_empty(), "the aura crosses the wire")
	assert_ne(enchantment.attached, "", "attached to the creature it enchants")
	enchantment.attached = "c99"
	assert_false(SgViewProtocol.game(view), "no attachment to a card outside this view")
	enchantment.attached = "not a handle"
	assert_false(SgViewProtocol.game(view), "an attachment is a handle, not free text")
