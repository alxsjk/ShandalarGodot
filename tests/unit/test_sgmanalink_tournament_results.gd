extends GutTest
## Public-ledger standings and advancement never invent results or tie-breaks.


func _event(count := 8, wins := 1) -> SgTournament:
	var event := SgTournament.new()
	assert_eq(event.configure({"name": "Results Cup", "limit": count, "wins": wins, "policy": "fixed",
		"decks": [{"name": "Knights", "cards": Array(StarterDecks.WHITE_KNIGHTS), "sideboard": []}]}, 4242), "")
	for i in count:
		var pid := event.register("Player %02d" % (i + 1), str(i).sha256_text())
		event.set_ready(pid, true)
	event.draw_round()
	return event


func _game(event: SgTournament, pair: Dictionary, winner := 0) -> void:
	for pid: int in pair.players: assert_eq(event.set_ready(pid, true), "")
	assert_eq(event.begin_game(pair.id), "")
	assert_true(event.record_game(pair.id, pair.game, winner))


func _finish(event: SgTournament) -> void:
	for round_index in SgTournament.MAX_ROUNDS:
		for pair: Dictionary in event.rounds.back():
			if pair.status == "bye": continue
			for game_index in int(event.config.wins): _game(event, pair)
		if event.phase == "complete": break
		assert_eq(event.draw_round(), "")
	assert_eq(event.phase, "complete")


func test_twenty_player_final_places_are_shared_by_elimination_round() -> void:
	var event := _event(20)
	_finish(event)
	var before := event.checkpoint()
	var rows := SgTournamentResults.standings(before)
	assert_eq(event.rounds.size(), 5)
	assert_eq(rows.size(), 20)
	assert_eq(rows[0].id, event.champion)
	var places: Array = []
	var wins := 0
	var losses := 0
	var byes := 0
	for row: Dictionary in rows:
		places.append(row.place)
		wins += row.series_won
		losses += row.series_lost
		byes += row.byes
	assert_eq(places, [1, 2, 3, 3, 5, 5, 5, 5, 9, 9, 9, 9, 9, 9, 9, 9, 17, 17, 17, 17])
	assert_eq(wins, 19)
	assert_eq(losses, 19)
	assert_eq(byes, 12)
	assert_false(rows[0].tied)
	assert_true(rows[2].tied)
	assert_eq(event.checkpoint(), before, "presenting results never mutates the ledger")


func test_draws_and_forfeits_do_not_invent_played_series_or_games() -> void:
	var event := _event(2, 3)
	var pair: Dictionary = event.rounds[0][0]
	_game(event, pair, -1)
	_game(event, pair, 0)
	assert_eq(event.withdraw(pair.players[1]), "")
	var rows := SgTournamentResults.standings(event.checkpoint())
	assert_eq(rows[0].games_won, 1)
	assert_eq(rows[0].draws, 1)
	assert_eq(rows[0].series_won, 0)
	assert_eq(rows[0].forfeits_won, 1)
	assert_eq(rows[1].forfeits_lost, 1)
	assert_eq(rows[1].games_lost, 1)
	assert_true(rows[1].withdrawn)


func test_cancelled_or_in_progress_events_never_publish_final_places() -> void:
	var event := _event(4)
	_game(event, event.rounds[0][0])
	for row: Dictionary in SgTournamentResults.standings(event.checkpoint()): assert_eq(row.place, 0)
	event.cancel()
	for row: Dictionary in SgTournamentResults.standings(event.checkpoint()):
		assert_eq(row.place, 0)
		assert_ne(row.status, "Champion")


func test_advancement_connects_every_published_winner_once_and_no_loser() -> void:
	var event := _event(20)
	assert_eq(SgTournamentResults.advancement(event.checkpoint()).links.size(), 0, "future random pairings stay unknown")
	_finish(event)
	var graph := SgTournamentResults.advancement(event.checkpoint())
	assert_eq(graph.nodes.size(), 31)
	assert_eq(graph.links.size(), 30)
	var sources := {}
	for link: Dictionary in graph.links:
		var source := event.pairing(link.from)
		var target := event.pairing(link.to)
		assert_eq(source.winner, link.player)
		assert_eq(target.players[link.seat], link.player)
		assert_false(sources.has(link.from), "a winner has only one next pairing")
		sources[link.from] = true
	var restored := SgTournament.new()
	assert_eq(restored.restore(SgProtocol.decode_payload(SgProtocol.encode(event.checkpoint()).to_ascii_buffer())), "")
	assert_eq(SgTournamentResults.standings(restored.checkpoint()), SgTournamentResults.standings(event.checkpoint()))
	assert_eq(SgTournamentResults.advancement(restored.checkpoint()), graph)
