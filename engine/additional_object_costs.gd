extends RefCounted
## Declarative, non-targeted object costs (CR 118, 601.2h, 602.2b).
## A group is {operation, filter, desc, count?, opponent?, zone?, kind?}.
## Every choice is gathered before payment. Disjoint assignment prevents
## a creature that is also a Swamp from paying both Drone sacrifices.

static func pools(g: MtgGame, pid: int, groups: Array, source_card: CardInstance = null) -> Array:
	var out: Array = []
	for group in groups:
		var owner := 1 - pid if group.get("opponent", false) else pid
		var zone: int = group.get("zone", Mtg.Zone.BATTLEFIELD)
		var candidates: Array[CardInstance] = []
		var source: Array = g.players[owner].hand if zone == Mtg.Zone.HAND else g.players[owner].battlefield
		for card in source:
			if zone == Mtg.Zone.HAND and card == source_card: continue
			if group.has("source_filter") and not group.source_filter.call(g, card, source_card): continue
			if group.operation == "tap" and card.tapped: continue
			if group.operation == "untap" and not card.tapped: continue
			if group.filter.call(card): candidates.append(card)
		for unused in int(group.get("count", 1)): out.append({"group": group, "cards": candidates.duplicate()})
	return out

static func can_assign(slots: Array, index := 0, used := {}) -> bool:
	if index >= slots.size(): return true
	for card in slots[index].cards:
		if used.has(card.id): continue
		var next := used.duplicate()
		next[card.id] = true
		if can_assign(slots, index + 1, next): return true
	return false

static func refusal(g: MtgGame, pid: int, groups: Array, source: CardInstance = null) -> String:
	return "" if can_assign(pools(g, pid, groups, source)) else "not enough distinct eligible cards to pay the additional costs"

static func choose(g: MtgGame, pid: int, source: CardInstance, groups: Array, replay: Dictionary) -> Array:
	var slots := pools(g, pid, groups, source)
	var chosen: Array = []
	var used := {}
	for index in slots.size():
		var group: Dictionary = slots[index].group
		var offered: Array[CardInstance] = []
		for card in slots[index].cards:
			if used.has(card.id): continue
			var next := used.duplicate()
			next[card.id] = true
			if can_assign(slots, index + 1, next): offered.append(card)
		var prompt := "%s %s" % [String(group.operation).capitalize(), group.desc]
		if group.operation == "counter": prompt = "Put a %s counter on %s" % [group.kind, group.desc]
		var question := g._cost_question(pid, source, PlayerChoice.Kind.CARD, prompt)
		question.candidates = offered
		if g._hold_cost_choice(question, replay): return []
		var pick := g._ask_cost_card(pid, source, offered, prompt)
		used[pick.id] = true
		chosen.append({"group": group, "card": pick})
	return chosen

static func pay(g: MtgGame, pid: int, choices: Array) -> Array:
	var receipt: Array = []
	for choice in choices:
		var card: CardInstance = choice.card
		receipt.append({"id": card.id, "stamp": card.layer_timestamp, "mana_value": card.data.cost.mana_value()})
		match String(choice.group.operation):
			"sacrifice": g.sacrifice_permanent(card)
			"tap": g.tap_permanent(card)
			"untap": g.untap_permanent(card)
			"discard": g.discard_cards(pid, [card], false)
			"counter": g.add_counters(card, choice.group.kind)
	return receipt
