class_name SgTournamentResults
extends RefCounted
## [QoL] Read-only tournament results derived from the public draw ledger.
## Shared places follow elimination rounds, never invented tie-break matches.
## Byes and forfeits are separate from played series and recorded game scores.


static func standings(view: Dictionary) -> Array:
	var rows: Array = []
	var indexed := {}
	for player: Dictionary in view.entrants:
		var row := {"id": int(player.id), "name": String(player.name), "deck_name": String(player.get("deck_name", "")),
			"place": 0, "tied": false, "round": 0, "series_won": 0, "series_lost": 0,
			"games_won": 0, "games_lost": 0, "draws": 0, "byes": 0, "forfeits_won": 0, "forfeits_lost": 0,
			"withdrawn": bool(player.withdrawn), "active": not player.withdrawn, "status": "Registered", "last_pair": {}}
		rows.append(row)
		indexed[row.id] = row
	for r in view.rounds.size():
		for pair: Dictionary in view.rounds[r]:
			for seat in 2:
				var pid := int(pair.players[seat])
				if pid == 0 or not indexed.has(pid): continue
				var row: Dictionary = indexed[pid]
				row.round = r + 1
				row.last_pair = pair
				row.games_won += int(pair.wins[seat])
				row.games_lost += int(pair.wins[1 - seat])
				row.draws += int(pair.draws)
				if pair.status == "bye": row.byes += 1
				elif pair.status == "finished":
					var won: bool = int(pair.winner) == pid
					if pair.reason == "Series won": row["series_won" if won else "series_lost"] += 1
					elif pair.reason == "Withdrawal": row["forfeits_won" if won else "forfeits_lost"] += 1
				row.active = not row.withdrawn and (pair.status in ["waiting", "playing"] or int(pair.winner) == pid)
	var champion := int(view.get("champion", 0))
	var final_places: bool = view.phase == "complete" and champion != 0
	for row: Dictionary in rows:
		if row.id == champion: row.status = "Champion"
		elif row.withdrawn: row.status = "Withdrawn · R%d" % int(row.round)
		elif view.phase == "cancelled": row.status = "Cancelled"
		elif view.phase == "registration": row.status = "Registered"
		elif not row.active: row.status = "Eliminated · R%d" % int(row.round)
		elif row.last_pair.get("status", "") == "playing": row.status = "Playing · R%d" % int(row.round)
		elif row.last_pair.get("status", "") == "waiting": row.status = "Waiting · R%d" % int(row.round)
		else: row.status = "Through · R%d" % int(row.round)
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_depth := SgTournament.MAX_ROUNDS + 1 if a.id == champion else int(a.round)
		var b_depth := SgTournament.MAX_ROUNDS + 1 if b.id == champion else int(b.round)
		if not final_places and a.active != b.active: return a.active
		if a_depth != b_depth: return a_depth > b_depth
		if a.name.nocasecmp_to(b.name) != 0: return a.name.nocasecmp_to(b.name) < 0
		return a.id < b.id)
	var previous_depth := -1
	var place := 0
	for i in rows.size():
		var row: Dictionary = rows[i]
		var depth := SgTournament.MAX_ROUNDS + 1 if row.id == champion else int(row.round)
		if final_places:
			if depth != previous_depth: place = i + 1
			row.place = place
			previous_depth = depth
		row.erase("last_pair")
	for row: Dictionary in rows:
		if row.place == 0: continue
		for other: Dictionary in rows:
			if row.id != other.id and row.place == other.place: row.tied = true
	return rows


static func active(view: Dictionary, pid: int) -> bool:
	for row: Dictionary in standings(view):
		if row.id == pid: return row.active and view.phase in ["registration", "running"]
	return false


static func advancement(view: Dictionary) -> Dictionary:
	# Only connect actual published winners to their actual next pairing.
	# A future random draw is unknown; no fixed bracket slots are promised.
	var nodes: Array = []
	var links: Array = []
	var previous := {}
	for r in view.rounds.size():
		var current := {}
		for pair: Dictionary in view.rounds[r]:
			var node := {"id": int(pair.id), "round": r + 1, "pair": pair.duplicate(true), "parents": []}
			for seat in 2:
				var pid := int(pair.players[seat])
				if previous.has(pid):
					links.append({"from": int(previous[pid]), "to": int(pair.id), "player": pid, "seat": seat})
					node.parents.append(int(previous[pid]))
			nodes.append(node)
			if int(pair.winner) != 0: current[int(pair.winner)] = int(pair.id)
		previous = current
	return {"nodes": nodes, "links": links, "rounds": view.rounds.size()}
