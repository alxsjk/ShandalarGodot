extends RefCounted
## Drought's additional cost, shared by spells, stack abilities and mana
## abilities. Printed black symbols, not the color of mana actually spent.

static func amount(g: MtgGame, cost: ManaCost) -> int:
	return 0 if cost == null else g.black_symbol_sacrifices * int(cost.colored.get(Mtg.ManaColor.B, 0))

static func swamps(g: MtgGame, pid: int, excluded: Array = []) -> Array[CardInstance]:
	var out: Array[CardInstance] = []
	for i in g.players[pid].battlefield:
		if i.is_land() and i.has_subtype("swamp") and not excluded.has(i): out.append(i)
	return out

## Bipartite cost matching: the same permanent cannot pay two sacrifices
## or an exile and sacrifice. Each group describes a remaining cost slot.
static func feasible(pool: Array, needed: int, groups: Array, reserved: Array = []) -> bool:
	var slots: Array = []
	for group in groups:
		for _n in int(group.count): slots.append(group.bodies)
	for _n in needed: slots.append(pool)
	slots.sort_custom(func(a: Array, b: Array) -> bool: return a.size() < b.size())
	var owners := {}
	for n in slots.size():
		if not _match(n, slots, owners, {}, reserved): return false
	return true
static func _match(slot: int, slots: Array, owners: Dictionary, visited: Dictionary, reserved: Array) -> bool:
	for i in slots[slot]:
		if reserved.has(i) or visited.has(i.id): continue
		visited[i.id] = true
		if not owners.has(i.id) or _match(int(owners[i.id]), slots, owners, visited, reserved):
			owners[i.id] = slot
			return true
	return false

static func choose(g: MtgGame, pid: int, source: CardInstance, cost: ManaCost, replay: Dictionary, groups: Array = [], excluded: Array = []) -> Array[CardInstance]:
	var needed := amount(g, cost)
	var pool := swamps(g, pid, excluded)
	var picks: Array[CardInstance] = []
	while picks.size() < needed:
		var eligible: Array[CardInstance] = []
		for i in pool:
			var proposed := picks.duplicate()
			proposed.append(i)
			if not picks.has(i) and feasible(pool, needed - proposed.size(), groups, proposed): eligible.append(i)
		if eligible.is_empty(): return [] # validated before the first question
		var q := g._cost_question(pid, source, PlayerChoice.Kind.CARD, "Drought: sacrifice a Swamp (%d/%d)" % [picks.size() + 1, needed])
		q.candidates = eligible
		if g._hold_cost_choice(q, replay): return []
		picks.append(g._ask_cost_card(pid, source, eligible, q.prompt))
	return picks

static func can_pay(g: MtgGame, pid: int, cost: ManaCost, groups: Array = [], excluded: Array = []) -> bool:
	var needed := amount(g, cost)
	if needed == 0: return true
	return feasible(swamps(g, pid, excluded), needed, groups)
