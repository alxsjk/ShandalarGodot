class_name AiObservation
extends RefCounted
## [QoL] The information boundary for planning and its cache keys.
## No game reference, opponent decklist, hidden hand identity, library
## order or random-generator state is returned. Records contain values only.


static func capture(game: MtgGame, seat: int, ignore_own: Array = [],
		ignore_own_resources := false) -> Dictionary:
	var out := {"seat": seat, "turn": game.turn_number, "step": game.current_step(),
		"active": game.active_player, "priority": game.priority_player,
		"attackers": game.awaiting_attackers, "blockers": game.awaiting_blockers,
		"damage_window": game.awaiting_damage_prevention,
		"regeneration_window": game.awaiting_regeneration,
		"over": game.game_over, "players": [], "stack": []}
	for player in game.players:
		var own: bool = player.id == seat
		var record := {"life": player.life, "hand_count": player.hand.size(),
			"library_count": player.library.size(), "battlefield": [],
			"graveyard": [], "exile": [], "ante": [], "known_hand": []}
		for card in player.hand:
			if own and ignore_own.has(card.id):
				record["hand_count"] -= 1
				continue
			if own or player.hand_revealed or card.revealed_in_hand:
				record["known_hand"].append(_card(card, true))
		for zone in ["battlefield", "graveyard", "exile", "ante"]:
			for card in player.get(zone):
				if own and zone == "battlefield" and ignore_own.has(card.id): continue
				# Face-down exile is not automatically visible to its owner
				# (Necropotence grants neither player permission to look).
				var entry := _card(card, (own and zone != "exile") or not card.face_down or (zone == "exile" and card.exile_visible_to == seat))
				if own and ignore_own_resources and zone == "battlefield" \
						and not card.cur_mana_abilities.is_empty():
					entry.erase("tapped")
				record[zone].append(entry)
		if not (own and ignore_own_resources):
			record["mana"] = _values(player.mana_pool)
		# Only the exposed top is observable, and only after the engine has
		# made it public. Never retain the rest of a library, including ours.
		if player.top_card_revealed and not player.library.is_empty():
			record["revealed_top"] = _card(player.library.back(), true)
		out["players"].append(record)
	for item in game.stack:
		var targets: Array = []
		for target in item.targets:
			targets.append([target.is_player, target.player_id, target.instance_id,
				target.is_damage, target.packet_id, target.amount])
		out["stack"].append({"id": item.id, "controller": item.controller,
			"card": item.card.id if item.card != null else -1,
			"x": item.x_value, "mode": item.mode, "targets": targets})
	return out


static func key(game: MtgGame, seat: int, ignore_own: Array = [],
		ignore_own_resources := false) -> String:
	return JSON.stringify(capture(game, seat, ignore_own, ignore_own_resources))


static func _card(card: CardInstance, known: bool) -> Dictionary:
	if not known:
		return {"id": card.id, "face_down": true, "controller": card.controller_id,
			"tapped": card.tapped, "damage": card.damage, "power": card.cur_power,
			"toughness": card.cur_toughness}
	var record := _values(card)
	record["name"] = card.data.card_name
	return record


static func _values(object: Object) -> Dictionary:
	var out: Dictionary = {}
	for property in object.get_property_list():
		if not (int(property["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE): continue
		var value: Variant = object.get(property["name"])
		if _is_value(value):
			out[String(property["name"])] = value.duplicate(true) \
				if value is Array or value is Dictionary else value
	return out


static func _is_value(value: Variant) -> bool:
	if value is Object or value is Callable or value is Signal: return false
	if value is Array:
		for entry in value:
			if not _is_value(entry): return false
	if value is Dictionary:
		for entry in value:
			if not _is_value(entry) or not _is_value(value[entry]): return false
	return true
