extends GameTest
## Local protocol/referee boundaries. Tests deliberately substitute hidden state.


func _message(action: Dictionary) -> Dictionary:
	return {"v": SgProtocol.VERSION, "type": "command", "seq": 1, "room": "", "revision": 0, "action": action}


func test_lan_addresses_and_invitations_refuse_public_or_executable_inputs() -> void:
	for address in ["10.0.0.2", "172.16.0.3", "172.31.255.1", "192.168.88.2", "169.254.3.1", "127.0.0.1"]:
		assert_true(SgLanInvite.address(address), address)
	for address in [null, 123, "8.8.8.8", "172.32.0.1", "172.15.0.1", "0.0.0.0", "255.255.255.255",
		"::1", "192.168.001.1", "localhost", "https://192.168.0.1", "192.168.0.1:80", "192.168.0.1/path"]:
		assert_false(SgLanInvite.address(address), str(address))
	for invitation in ["", "sglan1:", "sglan1:@@@=", "sglan1:" + "a".repeat(8192),
		"sglan1:" + Marshalls.utf8_to_base64('{"address":"8.8.8.8"}'),
		"sglan1:" + Marshalls.utf8_to_base64("[".repeat(50))]:
		assert_true(SgLanInvite.parse(invitation).is_empty())


func test_lan_discovery_rejects_spoofed_stale_or_oversized_listings() -> void:
	var scanner := SgLanDiscovery.new()
	add_child_autofree(scanner)
	scanner.scanning = true
	scanner._nonce = "b".repeat(64)
	var response := {"v": SgProtocol.VERSION, "type": "sg-lan-host", "nonce": scanner._nonce,
		"host": {"address": "192.168.0.5", "port": 17897, "name": "Forest Fox",
			"fingerprint": "a".repeat(64), "rooms": 1}}
	assert_true(scanner.accept_reply(response, "192.168.0.5", 100))
	assert_false(scanner.accept_reply(response, "192.168.0.6", 100), "no redirected discovery targets")
	response.nonce = "c".repeat(64)
	assert_false(scanner.accept_reply(response, "192.168.0.5", 100), "unrelated search response")
	response.nonce = scanner._nonce
	response.host.name = "[url=bad]host[/url]"
	assert_false(scanner.accept_reply(response, "192.168.0.5", 100))
	response.host.name = "Forest Fox"
	response.host["access"] = "secret"
	assert_false(scanner.accept_reply(response, "192.168.0.5", 100))
	response.host.erase("access")
	for i in SgLanDiscovery.MAX_HOSTS + 10:
		response.host.port = 18000 + i
		scanner.accept_reply(response, "192.168.0.5", 100)
	assert_eq(scanner.hosts.size(), SgLanDiscovery.MAX_HOSTS)
	scanner.expire(100 + SgLanDiscovery.EXPIRES_MS)
	assert_true(scanner.hosts.is_empty())
	scanner.stop()


func test_server_dtos_validate_nested_shapes_before_ui_use() -> void:
	var duel := SgPracticeMatch.new(42)
	var view := duel.view(0)
	assert_true(SgViewProtocol.game(view))
	for key in view.keys():
		var broken := view.duplicate(true)
		broken.erase(key)
		assert_false(SgViewProtocol.game(broken), "required game field: " + key)
	for value in [null, [], {"players": []}, {"actor": 999}]:
		assert_false(SgViewProtocol.game(value))
	var broken := view.duplicate(true)
	broken.players[0].battlefield = [null]
	assert_false(SgViewProtocol.game(broken))
	broken = view.duplicate(true)
	broken.hand[0].name = "../../private"
	assert_false(SgViewProtocol.game(broken))
	broken = view.duplicate(true)
	broken.players[1]["hand"] = view.hand
	assert_false(SgViewProtocol.game(broken), "enemy hand is not an allowed field")
	assert_false(SgViewProtocol.valid({"type": "welcome", "v": SgProtocol.VERSION,
		"resume": "a".repeat(64), "seq": {}, "guest": "Fox"}))
	assert_false(SgViewProtocol.valid({"type": "ack", "seq": 1, "ok": "yes", "error": ""}))


func test_text_effect_snapshots_are_public_detached_and_cleared() -> void:
	var host := put_battlefield(0, "Swamp")
	g.change_text(host, "land_type", "swamp", "island")
	host.memory["private_note"] = "SECRET library choice"
	var duel := SgPracticeMatch.new(42)
	duel.game = g
	var cards := duel._cards(1, [host])
	assert_true(SgViewProtocol.cards(cards))
	assert_eq(cards[0].text_effects, [{"kind": "land_type", "from": "swamp", "to": "island"}])
	assert_false(JSON.stringify(cards).contains("SECRET"))
	cards[0].text_effects[0].to = "forest"
	assert_eq(host.text_changes[0].to, "island", "the snapshot cannot mutate the engine")
	host.face_down = true
	cards = duel._cards(1, [host])
	assert_true(cards[0].text_effects.is_empty(), "a masked snapshot reveals no effect history")
	assert_true(SgViewProtocol.cards(cards))
	cards[0].text_effects = [{"kind": "land_type", "from": "swamp", "to": "island"}]
	assert_false(SgViewProtocol.cards(cards), "the client also rejects masked effect history")
	host.face_down = false
	g.return_to_hand(host)
	assert_true(duel._cards(0, [host])[0].text_effects.is_empty(), "no stale reminder in another zone")


func test_text_effect_protocol_rejects_malformed_or_unbounded_records() -> void:
	var valid := [
		{"kind": "land_type", "from": "swamp", "to": "island"},
		{"kind": "color_word", "from": Mtg.ManaColor.W, "to": Mtg.ManaColor.G},
		{"kind": "mana_color", "from": Mtg.ManaColor.W, "to": Mtg.ManaColor.C},
		{"kind": "circle_color", "to": Mtg.ManaColor.G},
	]
	assert_true(SgViewProtocol.text_effects(valid))
	assert_true(SgViewProtocol.text_effects(JSON.parse_string(JSON.stringify(valid))))
	for invalid in [null, {}, [null], [{}], [{"kind": "unknown", "from": 1, "to": 2}],
		[{"kind": "land_type", "from": "swamp", "to": "../../private"}],
		[{"kind": "land_type", "from": [], "to": "island"}],
		[{"kind": "color_word", "from": true, "to": 2}],
		[{"kind": "color_word", "from": 1, "to": 3}],
		[{"kind": "color_word", "from": 1, "to": Mtg.ManaColor.C}],
		[{"kind": "mana_color", "from": 1, "to": 1.5}],
		[{"kind": "circle_color", "to": 1, "private": "secret"}],
		[{"kind": "circle_color", "to": NAN}]]:
		assert_false(SgViewProtocol.text_effects(invalid), str(invalid))
	var oversized: Array = []
	oversized.resize(SgProtocol.MAX_CARDS + 1)
	oversized.fill(valid[0])
	assert_false(SgViewProtocol.text_effects(oversized))
	var old_hello := {"v": SgProtocol.VERSION - 1, "type": "hello", "access": "0".repeat(64),
		"resume": "", "nickname": "", "build": SgCompatibility.fingerprint()}
	assert_false(SgProtocol.valid(old_hello), "old clients cannot silently drop reminder fields")


func test_temporary_names_are_bounded_display_text_not_credentials() -> void:
	var hello := {"v": SgProtocol.VERSION, "type": "hello", "access": "0".repeat(64),
		"resume": "", "nickname": "", "build": SgCompatibility.fingerprint()}
	for value in ["", "Silver Fox", "Forest-7", "a".repeat(SgProtocol.NICKNAME_LIMIT)]:
		hello.nickname = value
		assert_true(SgProtocol.valid(hello), str(value))
	for value in [123, null, true, " ", " Silver", "Silver ", "a".repeat(21),
		"Fox\nGuest 1", "Fox\t", "Fox (Guest 1)", "[b]Fox[/b]", "Föx"]:
		hello.nickname = value
		assert_false(SgProtocol.valid(hello), str(value))
	hello.nickname = "Fox"
	hello.erase("nickname")
	assert_false(SgProtocol.valid(hello), "old handshake cannot silently omit the new field")


func test_protocol_refuses_unknown_fields_methods_types_and_unbounded_payloads() -> void:
	assert_true(SgProtocol.valid(_message({"op": "pass"})))
	for action in [{"op": "win"}, {"op": "pass", "pid": 1},
		{"op": "play", "card": 123}, {"op": "ready", "value": 1},
		{"op": "damage", "points": [["c1", -1]]},
		{"op": "block", "pairs": [["c1", "c2", "c3"]]},
		{"op": "host", "name": "[url=bad]spoof[/url]"}]:
		assert_false(SgProtocol.valid(_message(action)), str(action))
	for value in [-1, 0, 1.5, INF, NAN, "1", true]:
		var message := _message({"op": "pass"})
		message.seq = value
		assert_false(SgProtocol.valid(message), str(value))
	for text in ["[]", "{}", "{broken", "[".repeat(100), " ".repeat(32769)]:
		assert_eq(SgProtocol.decode(text.to_utf8_buffer()), {})
	assert_eq(SgProtocol.decode(PackedByteArray([255, 254])), {})
	var decoded := SgProtocol.decode(JSON.stringify(_message({"op": "pass"})).to_utf8_buffer())
	assert_true(SgProtocol.valid(decoded), "JSON integer-valued floats are accepted")
	assert_eq(decoded.action, {"op": "pass"})


func test_fixed_practice_pool_has_only_the_supported_card_behaviors() -> void:
	var duel := SgPracticeMatch.new(42)
	assert_eq(duel.game.players[0].deck_names.size(), 40)
	for name in SgPracticeMatch.CREATURES:
		var card := CardRegistry.get_card(name)
		assert_not_null(card)
		assert_true(card.activated_abilities.is_empty(), name)
		assert_true(card.triggered_abilities.is_empty(), name)
		assert_true(card.spell_effects.is_empty(), name)
	assert_true(duel.game.rules.mana_burn)
	assert_true(duel.game.rules.free_damage_assignment)


func test_views_do_not_change_with_opponent_hand_library_order_or_rng() -> void:
	var duel := SgPracticeMatch.new(42)
	var baseline := JSON.stringify(duel.view(0))
	duel.game.players[1].hand[0].data = CardRegistry.get_card("Black Lotus")
	duel.game.players[0].library.reverse()
	duel.game.players[1].library.reverse()
	duel.game.rng.randi()
	assert_eq(JSON.stringify(duel.view(0)), baseline)
	assert_false(baseline.contains("Black Lotus"))
	assert_false(baseline.contains("seed"))
	assert_false(baseline.contains("rng"))
	assert_false(baseline.contains("deck_names"))
	assert_false(duel.view(0).players[1].has("hand"))
	assert_false(duel.view(0).players[0].has("library"))
	assert_eq(duel.view(-1), {})
	duel.game.adjust_life(1, -1)
	assert_ne(JSON.stringify(duel.view(0)), baseline, "public information still updates")


func test_view_is_detached_and_private_handles_cannot_name_opponent_cards() -> void:
	var duel := SgPracticeMatch.new(42)
	var view := duel.view(0)
	view.players[0].life = 999
	view.hand.clear()
	assert_eq(duel.game.players[0].life, 20)
	assert_eq(duel.game.players[0].hand.size(), 7)
	assert_false(duel.view(0).hand[0].id is int)
	assert_ne(duel.act(0, {"op": "play", "card": "999"}), "")


func test_opening_choices_and_stale_hand_handles_are_enforced() -> void:
	var duel := SgPracticeMatch.new(42)
	var actor := duel.first_player
	var old := String(duel.view(actor).hand[0].id)
	assert_ne(duel.act(1 - actor, {"op": "keep"}), "")
	assert_eq(duel.act(actor, {"op": "mulligan"}), "")
	assert_null(duel._card(actor, old))
	assert_eq(duel.view(actor).hand.size(), 6)
	assert_eq(duel.act(actor, {"op": "keep"}), "")
	assert_eq(duel.act(1 - actor, {"op": "keep"}), "")
	assert_false(duel.game.mulligan_open)
	assert_ne(duel.act(actor, {"op": "mulligan"}), "")


func test_referee_uses_real_mana_casting_priority_and_concession() -> void:
	var duel := SgPracticeMatch.new(42)
	# The GameTest harness is the only place allowed to construct test state.
	duel.game = g
	g.set_agent(0, HumanAgent.new())
	g.set_agent(1, HumanAgent.new())
	g.rules.free_damage_assignment = true
	advance_to_step(Mtg.Step.MAIN1)
	var forest := give_hand(0, "Forest")
	var bear := give_hand(0, "Grizzly Bears")
	var other_forest := put_battlefield(0, "Forest")
	var view := duel.view(0)
	assert_eq(duel.act(0, {"op": "play", "card": duel._handle(0, forest)}), "")
	assert_false(duel._playable(0, bear), "not enough floating mana yet")
	assert_ne(duel.act(0, {"op": "play", "card": duel._handle(0, bear)}), "")
	assert_eq(duel.act(0, {"op": "tap", "card": duel._handle(0, forest)}), "")
	assert_eq(duel.act(0, {"op": "tap", "card": duel._handle(0, other_forest)}), "")
	assert_true(duel._playable(0, bear))
	assert_false(duel._playable(1, bear), "opposing seat gets no private playability hint")
	assert_eq(duel.act(0, {"op": "play", "card": duel._handle(0, bear)}), "")
	assert_eq(g.players[0].mana_pool.total(), 0)
	assert_eq(duel.act(0, {"op": "pass"}), "")
	assert_ne(duel.act(0, {"op": "pass"}), "", "wrong seat cannot act")
	assert_eq(duel.act(1, {"op": "pass"}), "")
	assert_eq(bear.zone, Mtg.Zone.BATTLEFIELD)
	assert_ne(view.hand.size(), duel.view(0).hand.size())
	assert_eq(duel.act(1, {"op": "concede"}), "")
	assert_eq(duel.view(0).winner, 0)


func test_referee_exposes_combat_damage_only_to_its_assigner() -> void:
	var duel := SgPracticeMatch.new(42)
	duel.game = g
	g.set_agent(0, HumanAgent.new())
	g.set_agent(1, HumanAgent.new())
	g.rules.free_damage_assignment = true
	var wurm := put_battlefield(0, "Craw Wurm")
	var bear1 := put_battlefield(1, "Grizzly Bears")
	var bear2 := put_battlefield(1, "Grizzly Bears")
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_eq(duel.act(0, {"op": "attack", "cards": [duel._handle(0, wurm)]}), "")
	for i in 8:
		if g.awaiting_blockers:
			break
		assert_eq(duel.act(g.priority_player, {"op": "pass"}), "")
	assert_true(g.awaiting_blockers)
	assert_eq(duel.act(1, {"op": "block", "pairs": [
		[duel._handle(1, bear1), duel._handle(1, wurm)],
		[duel._handle(1, bear2), duel._handle(1, wurm)]]}), "")
	for i in 8:
		if g.awaiting_damage_assignment:
			break
		assert_eq(duel.act(g.priority_player, {"op": "pass"}), "")
	assert_true(g.awaiting_damage_assignment)
	assert_eq(duel.view(0).damage_request.amount, 6)
	assert_eq(duel.view(1).damage_request, {})
	assert_ne(duel.act(1, {"op": "damage", "points": []}), "")
	assert_ne(duel.act(0, {"op": "damage", "points": [[duel._handle(0, bear1), 99]]}), "")
	assert_eq(duel.act(0, {"op": "damage", "points": [
		[duel._handle(0, bear1), 3], [duel._handle(0, bear2), 3]]}), "")
	assert_eq(bear1.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(bear2.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(wurm.zone, Mtg.Zone.GRAVEYARD, "simultaneous combat damage uses the real engine")


func test_cleanup_requires_exactly_the_owners_distinct_cards() -> void:
	var duel := SgPracticeMatch.new(42)
	duel.game = g
	g.set_agent(0, HumanAgent.new())
	for i in 9:
		give_hand(0, "Grizzly Bears")
	advance_to_step(Mtg.Step.CLEANUP)
	assert_true(g.awaiting_discard)
	var hand: Array = duel.view(0).hand
	assert_eq(g.discard_count, 2)
	assert_ne(duel.act(1, {"op": "discard", "cards": []}), "")
	assert_ne(duel.act(0, {"op": "discard", "cards": [hand[0].id, hand[0].id]}), "")
	assert_eq(duel.act(0, {"op": "discard", "cards": [hand[0].id, hand[1].id]}), "")
	assert_eq(g.players[0].hand.size(), 7)
