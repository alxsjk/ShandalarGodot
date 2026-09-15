extends RefCounted
## Coverage pilot, NOT an AiPlayer difficulty. Its entire input is one seat's
## received DTO and static printed card definitions. No referee, RNG or other
## client's state is accepted. Refusals are failures, not a silent skip list.

var _attempted: Dictionary = {}
var _paid := false


func choose(view: Dictionary, seat: int) -> Dictionary:
	match String(view.mode):
		"opening": return {"op": "keep"} if view.presentation.order else {"op": "order", "play": true}
		"choice":
			var picks: Array = []
			for i in int(view.choice.count): picks.append(i)
			return {"op": "choice", "picks": picks}
		"damage": return _damage(view.damage_request)
		"attack": return {"op": "attack", "cards": view.presentation.attackable.duplicate()}
		"block": return _blocks(view, seat)
		"discard":
			var cards: Array = []
			for i in int(view.discard_count): cards.append(view.hand[i].id)
			return {"op": "discard", "cards": cards}
	if not view.announcement.is_empty():
		var targets: Variant = _targets(view, seat)
		if targets == null or not view.presentation.draft.reachable:
			return {"op": "cancel"}
		if not _paid:
			_paid = true
			return {"op": "autopay", "excluded": [], "count": 1}
		return {"op": "submit", "targets": targets}
	_paid = false
	if view.active == seat and view.step in ["MAIN1", "MAIN2"] and view.stack.is_empty():
		for card in view.hand:
			if card.land and card.playable: return {"op": "play", "card": card.id}
	for row in view.presentation.cards:
		if not row.castable: continue
		var card := _card(view, row.id)
		if card.is_empty() or card.masked: continue
		var data := CardRegistry.get_card(card.name)
		var intent := EffectIntent.read(data.spell_effects, card.name)
		# Exercise responses as well as main phases, without throwing combat
		# pumps away in draw/upkeep or feeding a counter to an empty chain.
		var main: bool = view.active == seat and view.step in ["MAIN1", "MAIN2"] and view.stack.is_empty()
		if not main and not (intent.counters and not view.stack.is_empty()) \
			and not ((intent.removes or intent.damage > 0) and view.step in ["DECLARE_ATTACKERS", "DECLARE_BLOCKERS"]): continue
		if intent.counters and (view.stack.is_empty() or view.stack.back().controller == seat): continue
		var key := "%d/%s/%s" % [int(view.turn), view.step, row.id]
		if _attempted.has(key): continue
		_attempted[key] = true
		for option in row.abilities:
			if option.kind == "spell":
				return {"op": "prepare", "card": row.id, "kind": "spell", "index": 0,
					"x": int(option.budget), "mode": 0}
	return {"op": "pass"}


func _targets(view: Dictionary, seat: int) -> Variant:
	var result: Array = []
	var card := _card(view, view.presentation.draft.card)
	if card.is_empty(): return null
	var data := CardRegistry.get_card(card.name)
	var intent := EffectIntent.read(data.spell_effects, card.name)
	var hostile := intent.removes or intent.bounces or intent.damage > 0 or intent.damage_uses_x \
		or intent.discards != 0 or intent.mills > 0 or intent.counters
	if data.is_aura(): hostile = EffectIntent.aura_aim(data) == EffectIntent.Aim.HOSTILE
	var refs := {}
	for row in view.presentation.targets: refs[row.token] = row.ref
	for slot in view.announcement.slots:
		var candidates: Array = slot.targets.duplicate()
		if candidates.size() < int(slot.min): return null
		candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return _target_value(view, refs[a.id], seat, hostile) > _target_value(view, refs[b.id], seat, hostile))
		for i in int(slot.min):
			result.append([candidates[i].id, int(slot.divided) if i == 0 else 0])
	return result


func _target_value(view: Dictionary, ref: Dictionary, seat: int, hostile: bool) -> int:
	var controller := -1
	var value := 1
	if ref.kind == "player":
		controller = int(ref.id)
		value = 3
	elif ref.kind == "card":
		var card := _card(view, ref.id)
		controller = int(card.get("controller", -1))
		value = maxi(1, int(card.get("power", 0)) + int(card.get("toughness", 0)))
	elif ref.kind == "ability":
		for i in view.presentation.chain.size():
			if view.presentation.chain[i].id == ref.id: controller = int(view.stack[i].controller)
	return value + (100 if (controller != seat) == hostile else 0)


func _blocks(view: Dictionary, seat: int) -> Dictionary:
	var pairs: Array = []
	var used: Dictionary = {}
	var committed: Dictionary = {}
	for row in view.presentation.blockable:
		var blocker := _card(view, row[0])
		for handle in row[1]:
			if used.has(handle): continue
			var attacker := _card(view, handle)
			# A simple public-board trade/chump policy, not a strength benchmark.
			if int(blocker.power) >= int(attacker.toughness) - int(attacker.damage) \
				or int(blocker.toughness) - int(blocker.damage) > int(attacker.power) \
				or int(view.players[seat].life) <= int(attacker.power) + 3:
				pairs.append([row[0], handle])
				used[handle] = true
				committed[row[0]] = true
				break
	# When one body cannot trade, try a gang of the remaining legal blockers.
	# This deliberately exercises interactive division rather than allowing
	# every large attacker to sail through a one-blocker-only test policy.
	for attacker in view.players[1 - seat].battlefield:
		if not attacker.attacking or used.has(attacker.id): continue
		var gang: Array = []
		var power := 0
		for row in view.presentation.blockable:
			if committed.has(row[0]) or not row[1].has(attacker.id): continue
			gang.append(row[0])
			power += int(_card(view, row[0]).power)
			if power >= int(attacker.toughness) - int(attacker.damage): break
		if power < int(attacker.toughness) - int(attacker.damage): continue
		for handle in gang:
			pairs.append([handle, attacker.id])
			committed[handle] = true
	return {"op": "block", "pairs": pairs}


func _damage(request: Dictionary) -> Dictionary:
	var remaining := int(request.amount)
	var points: Array = []
	for i in request.targets.size():
		var target: Dictionary = request.targets[i]
		var amount := remaining if i == request.targets.size() - 1 else mini(remaining, int(target.lethal))
		if amount > 0: points.append([target.id, amount])
		remaining -= amount
	return {"op": "damage", "points": points}


func _card(view: Dictionary, handle: String) -> Dictionary:
	for card in view.hand:
		if card.id == handle: return card
	for player in view.players:
		for zone in ["battlefield", "graveyard", "exile", "ante", "revealed"]:
			for card in player[zone]:
				if card.id == handle: return card
	return {}


static func public_table(view: Dictionary) -> Dictionary:
	# Normalize viewer-local handles to public zone positions. Do not include
	# the private hand, private questions, target drafts or private history.
	var positions := {}
	for seat in 2:
		for zone in ["battlefield", "graveyard", "exile", "ante"]:
			for i in view.players[seat][zone].size():
				positions[view.players[seat][zone][i].id] = "%d/%s/%d" % [seat, zone, i]
	for i in view.presentation.chain.size():
		var item: Dictionary = view.presentation.chain[i]
		positions[item.id] = "chain/%d" % i
		if not item.face.is_empty(): positions[item.face.id] = "stack/%d" % i
	for i in view.presentation.packets.size(): positions[view.presentation.packets[i].id] = "damage/%d" % i
	var table := {}
	for key in ["mode", "actor", "active", "turn", "step", "first", "winner", "draw"]: table[key] = view[key]
	table.players = []
	for seat in 2:
		var player: Dictionary = view.players[seat]
		var summary := {}
		for key in ["life", "hand_count", "library_count", "mana_colors", "kept", "top"]: summary[key] = player[key]
		for zone in ["battlefield", "graveyard", "exile", "ante"]:
			summary[zone] = []
			for card in player[zone]:
				var face: Dictionary = card.duplicate(true)
				for key in ["id", "actions", "playable", "rules"]: face.erase(key)
				for key in ["blocking", "attached"]: face[key] = positions.get(face[key], "")
				summary[zone].append(face)
		table.players.append(summary)
	table.stack = []
	for item in view.stack:
		# Display target labels are relative (You/Opponent); structured chain
		# references are covered by their own projection regression tests.
		var row: Dictionary = item.duplicate(true)
		row.erase("targets")
		table.stack.append(row)
	table.chain = []
	for item in view.presentation.chain:
		var refs: Array = []
		for ref in item.refs: refs.append(_public_ref(ref, positions))
		table.chain.append(refs)
	table.packets = []
	for packet in view.presentation.packets:
		table.packets.append([positions.get(packet.source, ""), _public_ref(packet.target, positions), packet.amount, packet.combat])
	table.status = []
	for player in view.presentation.players: table.status.append(player.duplicate(true))
	return table


static func _public_ref(ref: Dictionary, positions: Dictionary) -> Dictionary:
	if ref.is_empty(): return {}
	return {"kind": ref.kind, "id": ref.id if ref.kind == "player" else positions.get(ref.id, ""), "amount": ref.amount}
