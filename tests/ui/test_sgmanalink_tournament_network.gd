extends GutTest
## Multiple real TLS clients, whole knockout lifecycle and private recovery.

var server: SgLocalServer
var clients: Array[SgLocalClient] = []
var scratch := ""
var refusals: Array = []
var campaign_journal: FileAccess
const Pilot = preload("res://tests/support/sg_network_pilot.gd")

class SeededServer extends SgLocalServer:
	var duel_seed := 4242
	var vary_seeds := false
	func _create_match(decks: Array, names: Array) -> SgPracticeMatch:
		var seed_value := duel_seed
		if vary_seeds: duel_seed += 1
		return SgPracticeMatch.new(seed_value, decks, names)


func before_each() -> void:
	clients.clear()
	refusals.clear()
	scratch = "user://tournament-tests/" + Crypto.new().generate_random_bytes(8).hex_encode()
	server = SeededServer.new()
	add_child_autofree(server)
	assert_eq(server.start_lan("127.0.0.1", 0, false), OK)


func after_each() -> void:
	if campaign_journal != null:
		campaign_journal.close()
		campaign_journal = null
	for client in clients: client.forget()
	server.stop()
	await get_tree().process_frame
	await get_tree().process_frame
	var dir := DirAccess.open(scratch)
	if dir != null:
		for filename in dir.get_files(): dir.remove(filename)
		DirAccess.remove_absolute(scratch)


func _until(predicate: Callable, frames := 800) -> bool:
	for i in frames:
		if predicate.call(): return true
		await get_tree().process_frame
	assert_true(false, "tournament network operation exceeded its frame budget")
	return false


func _client(name_value := "Guest") -> SgLocalClient:
	var client := SgLocalClient.new()
	add_child_autofree(client)
	clients.append(client)
	client.refused.connect(func(reason: String) -> void: refusals.append(reason))
	assert_eq(client.connect_invitation(server.invitation(), name_value), OK)
	await _until(func() -> bool: return client.online)
	return client


func _act(client: SgLocalClient, op: String, fields := {}) -> void:
	var action := fields.duplicate(true)
	action.op = op
	if op.begins_with("t_"): action.event = server.tournament.event.id
	assert_true(client.command(action), op + ": " + client.command_error)
	await _until(func() -> bool: return not client.busy())
	for i in 3: await get_tree().process_frame
	assert_true(client.online, client.status)
	assert_true(SgViewProtocol.valid(client.state))


func _open(owner: SgLocalClient, wins := 1, policy := "fixed", limit := 8) -> void:
	var options := {"name": "LAN Cup", "limit": limit, "wins": wins, "policy": policy,
		"decks": [] if policy == "own" else [{"name": "Knights", "cards": Array(StarterDecks.WHITE_KNIGHTS), "sideboard": []}]}
	assert_eq(server.open_tournament(options, owner._resume, scratch), "")
	await _until(func() -> bool: return owner.state.has("tournament"))


func _register(count: int, wins := 1) -> SgLocalClient:
	var owner := await _client("Organiser")
	await _open(owner, wins, "fixed", maxi(8, count))
	for i in count:
		var client := await _client("Entrant %d" % (i + 1))
		await _act(client, "t_join")
		await _act(client, "t_ready", {"value": true})
	await _act(owner, "t_start")
	assert_eq(server.tournament.event.phase, "running")
	return owner


func _by_member(pid: int) -> SgLocalClient:
	for client in clients:
		if int(client.state.get("tournament", {}).get("you", 0)) == pid: return client
	return null


func test_capacity_cleanup_preserves_the_disconnected_organiser_session() -> void:
	var owner := await _client("Organiser")
	await _open(owner)
	var owner_sid := server.tournament.organiser
	owner.set_process(false)
	owner._socket.close(-1)
	await _until(func() -> bool: return not server._connected(owner_sid))
	# Fill the roomless session cache, not the live connection limit. The
	# oldest entry is the reserved organiser and must never be scavenged.
	for i in SgLocalServer.MAX_SESSIONS - 1:
		var sid := 1000 + i
		server._sessions[sid] = {"peer": 0, "room": "", "seq": 0, "acks": {}, "nickname": "Expired",
			"disconnected_at": Time.get_ticks_msec(), "token_hash": str(sid).sha256_text()}
	var guest := await _client("Visitor")
	assert_true(guest.online)
	assert_true(server._sessions.has(owner_sid), "capacity cleanup must preserve tournament authority")
	owner.set_process(true)


func test_simultaneous_registration_and_readiness_do_not_conflict_between_players() -> void:
	var owner := await _client("Organiser")
	await _open(owner)
	var a := await _client("A")
	var b := await _client("B")
	for client in [a, b]: assert_true(client.command({"op": "t_join", "event": owner.state.tournament.id}))
	await _until(func() -> bool: return not a.busy() and not b.busy())
	for i in 4: await get_tree().process_frame
	assert_eq(server.tournament.event.entrants.size(), 2, "different entrants may register in the same frame")
	if server.tournament.event.entrants.size() != 2: return
	for client in [a, b]: assert_true(client.command({"op": "t_ready", "event": owner.state.tournament.id, "value": true}))
	await _until(func() -> bool: return not a.busy() and not b.busy())
	assert_true(server.tournament.event.entrants[0].ready)
	assert_true(server.tournament.event.entrants[1].ready, "different entrants may become ready in the same frame")
	assert_eq(refusals, [])
	await _act(owner, "t_start")
	await _act(a, "t_ready", {"value": true, "round": 0, "game": 0})
	assert_false(server.tournament.event.entrant(int(a.state.tournament.you)).ready, "an old registration click cannot ready a game")
	assert_eq(refusals.size(), 1)
	refusals.clear()
	for client in [a, b]: assert_true(client.command({"op": "t_ready", "event": owner.state.tournament.id, "value": true}))
	await _until(func() -> bool: return not a.busy() and not b.busy())
	assert_eq(server._rooms.size(), 1, "simultaneous game readiness opens exactly one table")
	assert_eq(refusals, [])


func test_twenty_entrants_and_separate_organiser_play_a_complete_knockout() -> void:
	var owner := await _register(20)
	assert_eq(server._sessions.size(), 21)
	for round_index in 5:
		var row: Array = server.tournament.event.rounds.back().duplicate(true)
		for pair: Dictionary in row:
			if pair.status == "bye": continue
			for pid: int in pair.players: await _act(_by_member(pid), "t_ready", {"value": true})
		assert_eq(server._rooms.size(), [4, 8, 4, 2, 1][round_index])
		assert_true(SgTournamentProtocol.view(owner.state.tournament), "the master accepts every live table")
		for pair: Dictionary in row:
			if pair.status == "bye": continue
			var a := _by_member(pair.players[0])
			var b := _by_member(pair.players[1])
			assert_eq(a.state.room.game.hand.size(), 7)
			assert_true(a.state.room.has("tournament"))
			assert_false(owner.state.has("hand"))
			assert_true(owner.state.room.is_empty(), "organiser cannot see a participant hand")
			await _act(b, "concede")
			await _act(a, "t_return")
			await _act(b, "t_return")
		assert_true(server._rooms.is_empty())
		if round_index < 4: await _act(owner, "t_next")
	assert_eq(server.tournament.event.phase, "complete")
	assert_gt(server.tournament.event.champion, 0)
	assert_eq(server.tournament.event.rounds.size(), 5)
	assert_eq(owner.state.tournament.tables.size(), 0)
	assert_eq(SgTournamentResults.standings(owner.state.tournament).size(), 20)
	assert_eq(SgTournamentResults.advancement(owner.state.tournament).links.size(), 30)
	assert_true(SgTournamentProtocol.checkpoint(server.tournament.event.checkpoint()))


func test_twenty_simultaneous_entrants_fill_registration_without_losing_ready_clicks() -> void:
	var owner := await _client("Organiser")
	await _open(owner, 1, "fixed", 20)
	var entrants: Array = []
	for i in 20: entrants.append(await _client("Entrant %d" % (i + 1)))
	for client: SgLocalClient in entrants:
		assert_true(client.command({"op": "t_join", "event": owner.state.tournament.id}))
	await _until(func() -> bool: return entrants.all(func(client: SgLocalClient) -> bool: return not client.busy()))
	assert_eq(server.tournament.event.entrants.size(), 20)
	for client: SgLocalClient in entrants:
		assert_true(client.command({"op": "t_ready", "event": owner.state.tournament.id, "value": true}))
	await _until(func() -> bool: return entrants.all(func(client: SgLocalClient) -> bool: return not client.busy()))
	for player: Dictionary in server.tournament.event.entrants: assert_true(player.ready)
	assert_eq(refusals, [])
	var late := await _client("Late visitor")
	await _act(late, "t_join")
	assert_eq(server.tournament.event.entrants.size(), 20)
	assert_eq(int(late.state.tournament.you), 0, "a twenty-first entrant stays an observer")
	assert_eq(refusals.size(), 1)
	assert_true(String(refusals[0]).contains("full"))
	refusals.clear()
	await _act(owner, "t_start")
	assert_eq(server.tournament.event.phase, "running")
	assert_eq(refusals, [])


func test_series_duplicate_concession_does_not_score_twice_and_next_game_is_fresh() -> void:
	await _register(2, 2)
	var pair: Dictionary = server.tournament.event.rounds[0][0]
	var a := _by_member(pair.players[0])
	var b := _by_member(pair.players[1])
	for client in [a, b]: await _act(client, "t_ready", {"value": true})
	var first_room: String = a.state.room.id
	assert_true(b.command({"op": "concede"}))
	var duplicate := b._pending_wire
	await _until(func() -> bool: return not b.busy())
	b._socket.send_text(duplicate)
	for i in 12: await get_tree().process_frame
	assert_eq(pair.wins, [1, 0])
	assert_eq(server.tournament.event.phase, "running")
	for client in [a, b]: await _act(client, "t_return")
	await _act(a, "t_ready", {"value": true, "round": 1, "game": 0})
	assert_false(server.tournament.event.entrant(int(a.state.tournament.you)).ready, "an old click cannot ready the next game in the same series")
	assert_eq(refusals.size(), 1)
	refusals.clear()
	for client in [a, b]: await _act(client, "t_ready", {"value": true})
	assert_ne(a.state.room.id, first_room)
	assert_eq(int(a.state.room.tournament.game), 2)
	assert_eq(a.state.room.game.hand.size(), 7)
	await _act(b, "concede")
	assert_eq(pair.wins, [2, 0])
	assert_eq(server.tournament.event.phase, "complete")


func test_authority_hidden_decks_recovery_and_organiser_forfeit() -> void:
	var owner := await _client("Same name")
	await _open(owner, 2, "own")
	var a := await _client("Same name")
	var b := await _client("Same name")
	for client in [a, b]:
		await _act(client, "t_join")
		await _act(client, "t_deck", {"name": "Private", "cards": Array(StarterDecks.WHITE_KNIGHTS), "sideboard": ["Terror"]})
		await _act(client, "t_ready", {"value": true})
	var code: String = a.state.tournament.code
	var pid := int(a.state.tournament.you)
	assert_false(SgProtocol.encode(owner.state).contains("Savannah Lions"))
	assert_false(SgProtocol.encode(b.state).contains(code))
	assert_ne(a.state.tournament.code, b.state.tournament.code)
	await _act(a, "t_start")
	assert_eq(server.tournament.event.phase, "registration", "visitor cannot start event")
	await _act(owner, "t_start")
	for client in [a, b]: await _act(client, "t_ready", {"value": true})
	var room_id: String = a.state.room.id
	var cards: Array = a.state.room.game.hand.duplicate(true)
	a.forget()
	await _until(func() -> bool: return not server.tournament.connected(pid))
	var replacement := await _client("Same name")
	await _act(replacement, "t_recover", {"code": "a".repeat(64)})
	assert_eq(int(replacement.state.tournament.you), 0)
	await _act(replacement, "t_recover", {"code": code})
	assert_eq(int(replacement.state.tournament.you), pid)
	assert_eq(replacement.state.room.id, room_id)
	assert_eq(replacement.state.room.game.hand, cards)
	await _act(b, "t_remove", {"player": pid})
	assert_false(server.tournament.event.entrant(pid).withdrawn)
	await _act(owner, "t_remove", {"player": pid})
	assert_true(server.tournament.event.entrant(pid).withdrawn)
	assert_eq(server.tournament.event.rounds[0][0].wins, [0, 0])
	assert_eq(server.tournament.event.phase, "complete")


func test_host_restart_preserves_series_scores_and_reclaims_only_with_codes() -> void:
	var owner := await _register(2, 2)
	var pair: Dictionary = server.tournament.event.rounds[0][0]
	var a := _by_member(pair.players[0])
	var b := _by_member(pair.players[1])
	var code_a: String = a.state.tournament.code
	var code_b: String = b.state.tournament.code
	var old_id: String = server.tournament.event.id
	for client in [a, b]: await _act(client, "t_ready", {"value": true})
	await _act(b, "concede")
	for client in [a, b]: await _act(client, "t_return")
	for client in [a, b]: await _act(client, "t_ready", {"value": true})
	var path := scratch.path_join(old_id + ".json")
	var checkpoint := SgTournamentStore.read_checkpoint(path)
	assert_eq(checkpoint.rounds[0][0].wins, [1.0, 0.0])
	var encoded := SgProtocol.encode(checkpoint)
	for secret in [code_a, code_b, server.access_code, owner._resume, a._resume]: assert_false(encoded.contains(secret))
	server.stop()
	for client in clients: client.forget()
	await get_tree().process_frame
	assert_eq(server.start_lan("127.0.0.1", 0, false), OK)
	assert_eq(owner.connect_invitation(server.invitation(), "Organiser"), OK)
	await _until(func() -> bool: return owner.online)
	assert_eq(server.open_tournament({}, owner._resume, scratch, path), "")
	for client in [a, b]: assert_eq(client.connect_invitation(server.invitation(), "New display name"), OK)
	await _until(func() -> bool: return a.online and b.online and owner.state.has("tournament"))
	await _act(a, "t_recover", {"code": code_a})
	await _act(b, "t_recover", {"code": code_b})
	assert_true(a.state.room.is_empty())
	assert_eq(a.state.tournament.id, old_id)
	assert_eq(a.state.tournament.rounds[0][0].wins, [1.0, 0.0])
	assert_eq(a.state.tournament.entrants[0].name, "Entrant 1 (Guest 2)")
	for client in [a, b]: await _act(client, "t_ready", {"value": true})
	assert_false(a.state.room.is_empty(), "restored game starts: " + str(refusals))
	if a.state.room.is_empty(): return
	assert_eq(a.state.room.game.mode, "opening")
	assert_eq(int(a.state.room.tournament.game), 3, "interrupted attempt is not silently reused")
	await _act(b, "concede")
	assert_eq(server.tournament.event.phase, "complete")


func test_failed_save_blocks_advancement_and_retry_is_explicit() -> void:
	var owner := await _register(2)
	var pair: Dictionary = server.tournament.event.rounds[0][0]
	var a := _by_member(pair.players[0])
	var b := _by_member(pair.players[1])
	# A file cannot be used as a directory. This produces a checked return
	# code without modifying permissions or any real player folder.
	var blocked_path := scratch.path_join("blocked")
	var file := FileAccess.open(blocked_path, FileAccess.WRITE)
	file.store_string("test fixture")
	file.close()
	server.tournament.folder = blocked_path
	await _act(a, "t_ready", {"value": true})
	assert_false(server.tournament.save_error.is_empty())
	await _act(b, "t_ready", {"value": true})
	assert_true(server._rooms.is_empty())
	server.tournament.folder = scratch
	await _act(owner, "t_retry")
	assert_true(server.tournament.save_error.is_empty())
	await _act(b, "t_ready", {"value": true})
	assert_eq(server._rooms.size(), 1)
	await _act(owner, "t_cancel")
	assert_true(server._rooms.is_empty())
	assert_eq(server.tournament.event.phase, "cancelled")
	await _act(owner, "t_close")
	assert_null(server.tournament)
	assert_false(owner.state.has("tournament"))
	await _act(owner, "host", {"name": "Friendly duel"})
	assert_false(owner.state.room.is_empty(), "ordinary hosting is still available")


func test_participating_organiser_keeps_host_alive_on_result_and_can_open_master_panel() -> void:
	var owner := await _client("Organiser")
	await _open(owner)
	var guest := await _client("Guest")
	for client in [owner, guest]:
		await _act(client, "t_join")
		await _act(client, "t_ready", {"value": true})
	await _act(owner, "t_start")
	for client in [owner, guest]: await _act(client, "t_ready", {"value": true})
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 600)
	add_child_autofree(viewport)
	var screen := SgDuelView.new()
	viewport.add_child(screen)
	screen.present(owner.state.room, true, false, true)
	for i in 4: await get_tree().process_frame
	var tournament_button: Button
	for node in screen._qol_reserve.get_children():
		if node is Button and node.text == "Tournament": tournament_button = node
	assert_not_null(tournament_button)
	assert_false(tournament_button.get_global_rect().intersects(screen._log_button.get_global_rect()), "Tournament control cannot cover the duel log")
	watch_signals(screen)
	tournament_button.pressed.emit()
	assert_signal_emitted(screen, "tournament_requested")
	var panel := SgTournamentPanel.new()
	viewport.add_child(panel)
	panel.present(owner.state.tournament, true, false, true)
	assert_true(panel._view.organiser)
	assert_false(panel._own().is_empty(), "organiser is also an entrant")
	await _act(owner, "concede")
	screen.present(owner.state.room, true, false, true)
	screen._on_game_over_dismissed()
	assert_signal_emitted(screen, "hall_requested")
	assert_signal_not_emitted(screen, "exit_requested")
	assert_true(server._listener.is_listening())
	for i in 4: await get_tree().process_frame


func _campaign_record(kind: String, details: Dictionary) -> void:
	var entry := details.duplicate(true)
	entry.event = kind
	if campaign_journal != null:
		campaign_journal.store_line(JSON.stringify(entry))
		campaign_journal.flush()
	if kind != "command": print("SG tournament ", JSON.stringify(entry))


func _campaign_roster(count: int, seed_value: int, varied: bool) -> SgLocalClient:
	var owner := await _client("Organiser")
	await _open(owner, 1, "own" if varied else "fixed", maxi(8, count))
	# Referee-only draw seed. No seed or privileged observation goes to a bot.
	server.tournament.event._draw_game.rng.seed = seed_value
	var paths := ["white_knights", "black_red_raiders", "blue_skies", "big_green", "mountain_artillery",
		"1997/duels/merfolk_shaman", "1997/duels/goblin_warlord", "1997/duels/nether_fiend"]
	for i in count:
		var client := await _client("Pilot %d" % (i + 1))
		await _act(client, "t_join")
		if varied:
			var deck := DeckList.load_file("res://decks/%s.deck" % paths[i % paths.size()])
			assert_eq(deck.errors, [])
			await _act(client, "t_deck", {"name": deck.deck_name, "cards": Array(deck.cards), "sideboard": Array(deck.sideboard)})
		await _act(client, "t_ready", {"value": true})
	assert_eq(refusals, [])
	await _act(owner, "t_start")
	return owner


func test_full_games_through_parallel_tables_and_final_use_only_seat_views() -> void:
	var count := clampi(int(OS.get_environment("SG_TOURNAMENT_CAMPAIGN_PLAYERS")), 4, 20)
	var varied := OS.get_environment("SG_TOURNAMENT_CAMPAIGN_VARIETY") == "1"
	var faults := OS.get_environment("SG_TOURNAMENT_CAMPAIGN_FAULTS") == "1"
	var seed_value := 4242
	if not OS.get_environment("SG_TOURNAMENT_CAMPAIGN_SEED").is_empty(): seed_value = int(OS.get_environment("SG_TOURNAMENT_CAMPAIGN_SEED"))
	var journal_path := OS.get_environment("SG_TOURNAMENT_CAMPAIGN_LOG")
	if not journal_path.is_empty():
		campaign_journal = FileAccess.open(journal_path, FileAccess.WRITE)
		assert_not_null(campaign_journal)
		if campaign_journal == null: return
	server.duel_seed = seed_value
	server.vary_seeds = varied
	var owner := await _campaign_roster(count, seed_value, varied)
	var total_commands := 0
	var finished_games := 0
	var totals := {"submit": 0, "blockers": 0, "damage": 0, "choice": 0, "cancel": 0, "duplicate": 0, "lost_ack": 0}
	_campaign_record("start", {"players": count, "seed": seed_value, "varied": varied, "faults": faults})
	for round_index in SgTournament.MAX_ROUNDS:
		var row: Array = server.tournament.event.rounds.back().duplicate(true)
		var pilots := {}
		var played := {}
		for pair: Dictionary in row:
			if pair.status == "bye": continue
			pilots[pair.id] = [Pilot.new(), Pilot.new()]
			played[pair.id] = {"commands": 0, "seed": server.duel_seed}
			for pid: int in pair.players: await _act(_by_member(pid), "t_ready", {"value": true})
		var deadline := Time.get_ticks_msec() + 240000
		var finished := false
		while not finished and total_commands < 30000 and Time.get_ticks_msec() < deadline:
			finished = true
			for pair: Dictionary in row:
				if pair.status == "bye": continue
				var a := _by_member(pair.players[0])
				var b := _by_member(pair.players[1])
				if a.state.room.game.mode == "finished": continue
				finished = false
				var seat := int(a.state.room.game.actor)
				var client: SgLocalClient = a if seat == 0 else b
				# This pilot sees one authorised DTO only, never another client's
				# hand, the tournament checkpoint or the host referee.
				var action: Dictionary = pilots[pair.id][seat].choose(client.state.room.game.duplicate(true), seat)
				var before := refusals.size()
				var fault := ""
				if faults:
					if int(played[pair.id].commands) % 97 == 13: fault = "duplicate"
					elif int(played[pair.id].commands) % 193 == 35: fault = "lost_ack"
				if not fault.is_empty(): client.set_process(false)
				var accepted := client.command(action)
				assert_true(accepted, client.command_error)
				if not accepted:
					client.set_process(true)
					return
				if not fault.is_empty():
					totals[fault] += 1
					var pending := client._pending_wire
					await get_tree().create_timer(0.09).timeout
					if fault == "duplicate": assert_eq(client._socket.send_text(pending), OK)
					else:
						client._socket.close(-1)
						client.reconnect()
					client.set_process(true)
				if not await _until(func() -> bool: return a.online and b.online and not client.busy() \
					and a.state.room.revision == b.state.room.revision and a.state.room.connected == [true, true] and b.state.room.connected == [true, true]): return
				assert_eq(refusals.size(), before, str(refusals))
				var table := Pilot.public_table(a.state.room.game)
				assert_eq(table, Pilot.public_table(b.state.room.game))
				for peer in [a, b]: assert_true(SgViewProtocol.valid(peer.state))
				_campaign_record("command", {"round": round_index + 1, "pair": pair.id, "number": played[pair.id].commands,
					"seat": seat, "action": action, "fault": fault, "public_hash": JSON.stringify(table).sha256_text(), "refusals": refusals.slice(before)})
				if refusals.size() != before or table != Pilot.public_table(b.state.room.game): return
				if action.op in ["submit", "damage", "choice", "cancel"]: totals[action.op] += 1
				if action.op == "block": totals.blockers += action.pairs.size()
				await get_tree().create_timer(0.025).timeout
				total_commands += 1
				played[pair.id].commands += 1
				if total_commands % 250 == 0: print("SG tournament campaign seed=", seed_value, " commands=", total_commands)
		assert_true(finished, "every tournament game finishes within bounds")
		if not finished: return
		for pair: Dictionary in row:
			if pair.status == "bye": continue
			var room: Dictionary = _by_member(pair.players[0]).state.room
			_campaign_record("game_finished", {"round": round_index + 1, "pair": pair.id, "seed": played[pair.id].seed,
				"names": room.names, "decks": room.deck_names, "commands": played[pair.id].commands,
				"turn": room.game.turn, "winner": room.game.winner, "draw": room.game.draw,
				"life": [room.game.players[0].life, room.game.players[1].life]})
			for pid: int in pair.players: await _act(_by_member(pid), "t_return")
			finished_games += 1
		assert_true(server._rooms.is_empty(), "finished tournament tables are reclaimed")
		assert_eq(server._sessions.size(), count + 1, "reconnects reuse their entrant session")
		if server.tournament.event.phase == "complete": break
		await _act(owner, "t_next")
	assert_eq(server.tournament.event.phase, "complete")
	assert_eq(finished_games, count - 1)
	assert_eq(refusals, [])
	var standings := SgTournamentResults.standings(owner.state.tournament)
	assert_eq(standings.size(), count)
	assert_eq(standings[0].id, int(owner.state.tournament.champion))
	for peer: SgLocalClient in clients:
		assert_eq(SgTournamentResults.standings(peer.state.tournament), standings, "all players and organiser agree on final standings")
	var restored := SgTournament.new()
	assert_eq(restored.restore(SgTournamentStore.read_checkpoint(scratch.path_join(server.tournament.event.id + ".json"))), "")
	# Compare both through the wire representation: Godot's JSON numbers
	# are floats, whereas restored ledger IDs/scores are normalized integers.
	var restored_wire := SgProtocol.decode_payload(SgProtocol.encode(restored.checkpoint()).to_ascii_buffer())
	assert_eq(SgTournamentResults.advancement(restored_wire), SgTournamentResults.advancement(owner.state.tournament))
	if faults:
		assert_gt(totals.duplicate, 0)
		assert_gt(totals.lost_ack, 0)
	_campaign_record("complete", {"seed": seed_value, "games": finished_games, "commands": total_commands, "counts": totals, "standings": standings})


func test_lobby_configuration_opens_registration_without_creating_a_duel() -> void:
	var had_folder := Settings.has_value(GamePaths.KEY_TOURNAMENTS)
	var saved_folder: Variant = Settings.get_value(GamePaths.KEY_TOURNAMENTS, null) if had_folder else null
	var viewport := SubViewport.new()
	viewport.size = Vector2i(960, 600)
	add_child_autofree(viewport)
	var lobby := SgLobby.new()
	viewport.add_child(lobby)
	lobby.service = server
	lobby._code.text = server.invitation()
	lobby._connect_local()
	await _until(func() -> bool: return lobby.client.online)
	lobby._show_page("tournament")
	lobby._tournament_panel._name_edit.text = "UI Cup"
	lobby._tournament_panel._welcome_edit.text = "Welcome to our LAN cup!"
	lobby._tournament_panel._folder_edit.text = scratch
	lobby._tournament_panel._limit.select(4)
	lobby._tournament_panel._wins.select(2)
	lobby._tournament_panel.find_child("TournamentOpenRegistration", true, false).pressed.emit()
	await _until(func() -> bool: return server.tournament != null and lobby.client.state.has("tournament"))
	assert_eq(server.tournament.event.config.wins, 3)
	assert_eq(server.tournament.event.config.limit, 6)
	assert_eq(server.tournament.folder, scratch)
	assert_eq(server.tournament.event.config.welcome, "Welcome to our LAN cup!")
	assert_false(JSON.stringify(lobby.client.state).contains(scratch), "the save folder remains host-local")
	assert_true(server._rooms.is_empty())
	assert_eq(lobby._page, "tournament")
	# Delete only this test-created event's own checkpoint, not other saves.
	var path := GamePaths.tournaments_folder().path_join(server.tournament.event.id + ".json")
	lobby._open_master()
	assert_true(is_instance_valid(lobby._master_overlay))
	await _act(lobby.client, "t_cancel")
	assert_true(is_instance_valid(lobby._master_overlay), "cancellation remains visible until the organiser closes the event")
	await _act(lobby.client, "t_close")
	assert_false(is_instance_valid(lobby._master_overlay), "closing the event must close the expanded Master Panel")
	assert_true(lobby._tournament_panel._setup_built, "the ordinary Tournament page is ready to host a new event")
	lobby.client.forget()
	server.stop()
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(path + suffix): DirAccess.remove_absolute(path + suffix)
	if had_folder: Settings.set_value(GamePaths.KEY_TOURNAMENTS, saved_folder)
	else: Settings.clear_value(GamePaths.KEY_TOURNAMENTS)


func test_normal_browser_discovers_named_tournament_and_invited_player_joins_with_welcome() -> void:
	var owner := await _client("Organiser")
	var options := {"name": "Friday LAN Cup", "welcome": "Welcome, duelists! Please be ready at 19:00.",
		"limit": 8, "wins": 1, "policy": "own", "decks": []}
	assert_eq(server.open_tournament(options, owner._resume, scratch), "")
	var advertiser := SgLanDiscovery.new()
	server.add_child(advertiser)
	server.discovery = advertiser
	assert_eq(advertiser.advertise({"address": "127.0.0.1", "port": server.port, "name": "Organiser",
		"fingerprint": server._lan_pem.sha256_text(), "rooms": 0}, 0), OK)
	server.poll()
	var lobby := SgLobby.new()
	add_child_autofree(lobby)
	clients.append(lobby.client)
	lobby._show_page("browser")
	lobby._scan_lan()
	lobby._discovery.query("127.0.0.1", advertiser._socket.get_local_port())
	await _until(func() -> bool: return lobby._discovery.hosts.size() == 1)
	var discovered: Dictionary = lobby._discovery.hosts.values()[0].host
	assert_eq(discovered.tournament, options.name)
	assert_false(JSON.stringify(discovered).contains(server.access_code))
	assert_false(discovered.has("welcome"), "welcome is shared inside the invited hall, not broadcast")
	lobby._refresh()
	var select: Button
	for button: Button in lobby._body.find_children("*", "Button", true, false):
		if button.text == "Select": select = button
	assert_not_null(select)
	if select == null: return
	select.pressed.emit()
	assert_eq(lobby._selected_host.tournament, options.name)
	assert_false(lobby.client.online, "discovery does not grant access")
	lobby._code.text = server.invitation()
	lobby._connect_local()
	await _until(func() -> bool: return lobby.client.online and lobby.client.state.has("tournament"))
	for i in 6: await get_tree().process_frame
	assert_eq(lobby._page, "tournament")
	assert_eq(lobby.client.state.tournament.config.welcome, options.welcome)
	assert_false(JSON.stringify(lobby.client.state).contains(ProjectSettings.globalize_path(scratch)))
	var message := lobby._tournament_panel.find_child("TournamentWelcome", true, false) as Label
	assert_not_null(message)
	assert_eq(message.text, options.welcome)
	var join: Button
	for button: Button in lobby._tournament_panel.find_children("*", "Button", true, false):
		if button.text == "Join tournament": join = button
	assert_not_null(join)
	if join == null: return
	join.pressed.emit()
	await _until(func() -> bool: return int(lobby.client.state.tournament.you) != 0 and not lobby.client.busy())
	var entrant := int(lobby.client.state.tournament.you)
	assert_eq(server.tournament.event.entrants.size(), 1)
	lobby.client.reconnect()
	await _until(func() -> bool: return lobby.client.online)
	assert_eq(int(lobby.client.state.tournament.you), entrant)
	assert_eq(lobby.client.state.tournament.config.welcome, options.welcome)
	assert_eq(SgTournamentStore.read_checkpoint(scratch.path_join(server.tournament.event.id + ".json")).config.welcome, options.welcome)
	assert_true(lobby.find_children("*", "Label", true, false).any(func(label: Label) -> bool: return label.text == "Local network only"))
	assert_eq(refusals, [])


func test_duplicate_draw_hostile_views_and_approved_deck_enforcement() -> void:
	var owner := await _client("Organiser")
	await _open(owner, 1, "selection")
	var a := await _client("A")
	var b := await _client("B")
	for client in [a, b]:
		await _act(client, "t_join")
		await _act(client, "t_choose", {"index": 0})
		await _act(client, "t_ready", {"value": true})
	var old_deck: Dictionary = a.state.tournament.deck.duplicate(true)
	await _act(a, "t_deck", {"name": "Different deck", "cards": Array(StarterDecks.BLACK_RED_RAIDERS), "sideboard": []})
	assert_eq(a.state.tournament.deck, old_deck, "another deck cannot bypass an approved list")
	assert_true(owner.command({"op": "t_start", "event": owner.state.tournament.id}))
	var duplicate := owner._pending_wire
	await _until(func() -> bool: return not owner.busy())
	var rounds: Array = owner.state.tournament.rounds.duplicate(true)
	owner._socket.send_text(duplicate)
	for i in 12: await get_tree().process_frame
	assert_eq(owner.state.tournament.rounds, rounds, "published draw cannot be rerolled by a replay")
	var view: Dictionary = owner.state.tournament.duplicate(true)
	for key in view.keys():
		var broken := view.duplicate(true)
		broken.erase(key)
		assert_false(SgTournamentProtocol.view(broken), "required tournament view field " + key)
	view.entrants[0]["hand"] = ["Black Lotus"]
	assert_false(SgTournamentProtocol.view(view), "extra hidden fields are rejected")
	view = owner.state.tournament.duplicate(true)
	view.rounds[0][0].players[1] = view.rounds[0][0].players[0]
	assert_false(SgTournamentProtocol.view(view), "self-pairing cannot enter the UI")
	view = owner.state.tournament.duplicate(true)
	view.tables.append({"pair": 81, "life": [20, 20], "turn": 1, "step": "UNTAP"})
	assert_false(SgTournamentProtocol.view(view), "a phantom final table cannot enter a first-round view")
	view.tables[0].pair = view.rounds[0][0].id
	assert_false(SgTournamentProtocol.view(view), "a table cannot claim a game before readiness starts it")


func test_result_save_failure_is_not_acknowledged_as_durable_success() -> void:
	var owner := await _register(2)
	var pair: Dictionary = server.tournament.event.rounds[0][0]
	var a := _by_member(pair.players[0])
	var b := _by_member(pair.players[1])
	for client in [a, b]: await _act(client, "t_ready", {"value": true})
	var blocked := scratch.path_join("blocked")
	var file := FileAccess.open(blocked, FileAccess.WRITE)
	file.store_string("test fixture")
	file.close()
	server.tournament.folder = blocked
	await _act(b, "concede")
	assert_false(refusals.is_empty(), "unsaved result reports the storage failure")
	assert_true(a.state.room.tournament.paused)
	assert_eq(pair.wins, [1, 0], "in-memory result is retained exactly once")
	var path := scratch.path_join(server.tournament.event.id + ".json")
	assert_eq(SgTournamentStore.read_checkpoint(path).rounds[0][0].wins, [0.0, 0.0])
	server.tournament.folder = scratch
	await _act(owner, "t_retry")
	assert_false(a.state.room.tournament.paused)
	assert_eq(SgTournamentStore.read_checkpoint(path).rounds[0][0].wins, [1.0, 0.0])


func test_checkpoint_backup_survives_a_damaged_primary_and_recovery_save() -> void:
	var owner := await _register(2)
	var path := scratch.path_join(server.tournament.event.id + ".json")
	assert_true(FileAccess.file_exists(path + ".bak"))
	var backup := SgTournamentStore.read_checkpoint(path + ".bak")
	assert_false(backup.is_empty())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{interrupted")
	file.close()
	assert_eq(SgTournamentStore.read_checkpoint(path), backup)
	assert_eq(server.tournament.save(), "")
	assert_eq(SgTournamentStore.read_checkpoint(path + ".bak"), backup, "bad primary did not replace the last good backup")
	assert_true(SgTournamentProtocol.checkpoint(SgTournamentStore.read_checkpoint(path)))
	assert_true(owner.online)
