extends GameTest
## Regression boundaries for the LAN stabilization: codec, combat, costs,
## filtered history and display-only allocations.

func _referee() -> SgPracticeMatch:
	var result := SgPracticeMatch.new(42)
	result.game = g
	result.view(0)
	return result

func test_codec_preserves_ascii_unicode_escaping_and_depth_guards() -> void:
	for value in ["plain", "Junún Efreet", "Ω 雪 😀", "quote \" slash \\ \n", "\\u1234"]:
		var message := {"text": value}
		var encoded := SgProtocol.encode(message)
		for byte in encoded.to_utf8_buffer(): assert_lt(byte, 128)
		assert_eq(SgProtocol.decode_payload(encoded.to_ascii_buffer()), message)
	assert_eq(SgProtocol.decode_payload("[".repeat(30).to_ascii_buffer()), {})
	assert_eq(SgProtocol.decode_payload(PackedByteArray([0xff, 0xfe])), {})
	assert_eq(SgProtocol.decode_payload(" ".repeat(SgProtocol.MAX_BYTES + 1).to_ascii_buffer()), {})
	assert_true(SgProtocol.token(SgCompatibility.fingerprint()))
	assert_eq(SgCompatibility.fingerprint(), SgCompatibility.fingerprint())

func test_block_matrix_bounds_each_dimension_not_total_relationships() -> void:
	var columns: Array = []
	for i in 512: columns.append("c%d" % i)
	assert_true(SgViewProtocol.block_matrix([["a", columns]]))
	assert_true(SgViewProtocol.block_matrix([["a", columns], ["b", ["c1"]]]), "513 legal relationships")
	columns.append("c512")
	assert_false(SgViewProtocol.block_matrix([["a", columns]]))
	assert_false(SgViewProtocol.block_matrix([["a", ["c1", "c1"]]]))
	assert_false(SgViewProtocol.block_matrix([["a", ["c1"]], ["a", ["c2"]]]))
	assert_false(SgViewProtocol.block_matrix([["a", "c1"]]))

func test_large_combat_view_validates_and_projection_knows_all_blocks() -> void:
	var attackers: Array = []
	var defenders: Array = []
	for i in 24: attackers.append(put_battlefield(0, "Grizzly Bears").id)
	for i in 24: defenders.append(put_battlefield(1, "Grizzly Bears"))
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, attackers))
	var ref := _referee()
	var state := ref.view(1)
	assert_true(SgViewProtocol.game(state))
	assert_eq(state.presentation.blockable.size(), 24)
	for row in state.presentation.blockable: assert_eq(row[1].size(), 24)
	var projection := SgDuelProjection.new()
	projection.ingest({"seat": 1, "game": state, "names": ["One", "Two"], "deck": {}})
	for blocker in projection.players[0].battlefield:
		for attacker in projection.players[1].battlefield:
			assert_eq(projection.block_refusal(blocker, attacker), "")

func test_x_uses_actual_colored_cost_and_restricted_mana() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var drain := give_hand(0, "Drain Life")
	for i in 3: put_battlefield(0, "Swamp")
	for i in 2: put_battlefield(0, "Mountain")
	assert_eq(SgPayment.budget(g, 0, drain, "spell", 0, ManaPlanner.sources(g, 0)), 2)
	var fireball := give_hand(1, "Fireball")
	put_battlefield(1, "Mountain")
	put_battlefield(1, "Mishra's Workshop")
	assert_eq(SgPayment.budget(g, 1, fireball, "spell", 0, ManaPlanner.sources(g, 1)), 0)

func test_journal_does_not_leak_draws_masked_identities_or_private_reveals() -> void:
	var ref := _referee()
	g.draw_cards(0, 1)
	assert_string_contains(JSON.stringify(ref.view(0).journal), "draws Forest")
	assert_false(JSON.stringify(ref.view(1).journal).contains("draws Forest"))
	g.reveal_information(0, "Private look", ["Black Lotus"])
	assert_false(JSON.stringify(ref.view(1).journal).contains("Black Lotus"))
	g.reveal_information(-1, "Public reveal", ["Ancestral Recall"])
	assert_string_contains(JSON.stringify(ref.view(1).journal), "Ancestral Recall")
	for i in SgJournal.LIMIT + 10: g.reveal_information(-1, "Public reveal", ["Island"])
	var entries: Array = ref.view(1).journal
	assert_eq(entries.size(), SgJournal.LIMIT)
	assert_true(SgViewProtocol.journal(entries))
	var projection := SgDuelProjection.new()
	var room := {"seat": 1, "game": ref.view(1), "names": ["One", "Two"], "deck": {}}
	projection.ingest(room)
	assert_string_contains(projection.log_lines[0], "Earlier online history")
	var size := projection.log_lines.size()
	projection.ingest(room)
	assert_eq(projection.log_lines.size(), size)
	entries[0].serial = entries[1].serial
	assert_false(SgViewProtocol.journal(entries))
