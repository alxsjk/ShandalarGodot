extends RefCounted
## Bounded, pure cost-first fallback for described mana converters. Normal
## mana plans retain ManaPlanner's existing fast path and source preferences.
## State transitions use the REAL payment policy, including generic-colour
## tie ordering and restrictions. No game callback, hidden zone or RNG runs.
## A search limit means an exotic payable combination may be declined; it
## never authorizes a speculative tap or manufactures a free conversion.

const MAX_STATES := 2048
const MAX_STEPS := 64

static func plan(sources: Array, cost: ManaCost, extra: int, usage: Array) -> Array:
	var pool := ManaPool.new()
	var actions: Array = []
	for row in sources:
		if row[0] != null:
			actions.append(row)
		if row.size() > 8:
			pool._mana = row[8].floating.duplicate()
			pool._restricted = row[8].restricted.duplicate(true)
	if not _possible(actions, pool, cost, extra, usage): return []
	var feed_usage := _feed_usage(actions, usage)
	var queue: Array = [{"pool": pool, "used": {}, "fuel": {}, "steps": [], "rank": 0.0}]
	var seen := {}
	var expanded := 0
	while not queue.is_empty() and expanded < MAX_STATES:
		var best := 0
		for i in range(1, queue.size()):
			if float(queue[i].rank) < float(queue[best].rank): best = i
		var state: Dictionary = queue[best]
		queue.remove_at(best)
		var current: ManaPool = state.pool
		if current.can_pay(cost, extra, usage):
			# Nonempty for callers that distinguish "payable" from failure.
			return state.steps if not state.steps.is_empty() else [[null, 0]]
		if state.steps.size() >= MAX_STEPS: continue
		var key := _key(state)
		if seen.has(key): continue
		seen[key] = true
		expanded += 1
		# Identical unused basics need not generate permutations. Include all
		# modes of a flexible source, never collapse different mana menus.
		var representatives := {}
		for row in actions:
			var id: int = row[0].id
			if state.used.has(id): continue
			var repeatable: bool = row.size() > 8 and bool(row[8].repeatable)
			var fuel_key: String = row[8].get("fuel_key", "") if row.size() > 8 else ""
			if fuel_key != "" and int(state.fuel.get(fuel_key, 0)) >= int(row[8].fuel): continue
			var activation: ManaCost = row[8].cost if row.size() > 8 else null
			var cost_usage: Array = row[8].get("cost_usage", []) if row.size() > 8 else []
			if activation != null:
				if not current.can_pay(activation, 0, cost_usage): continue
				# Net-neutral repeatable filters only fill missing coloured pips.
				if repeatable and fuel_key == "" and (activation.mana_value() == 0 or int(row[3]) > activation.mana_value()): continue
				if int(row[3]) <= activation.mana_value() \
						and current.amount_of(row[2]) >= int(cost.colored.get(row[2], 0)): continue
			elif not ManaPlanner.source_usable(row, feed_usage):
				continue
			var signature := "%s:%s:%s:%s:%s:%s" % [row[0].data.card_name, row[1], row[2], row[3], row[5], int(row[8].fuel) - int(state.fuel.get(fuel_key, 0)) if fuel_key != "" else -1]
			if representatives.has(signature): continue
			representatives[signature] = true
			if queue.size() >= MAX_STATES: break
			var next := ManaPool.new()
			next._mana = current._mana.duplicate()
			next._restricted = current._restricted.duplicate(true)
			if activation != null: next.pay(activation, 0, cost_usage)
			for output in _outputs(row):
				if output[2] == "": next.add(output[0], output[1])
				else: next.add_restricted(output[0], output[1], output[2])
			var used: Dictionary = state.used.duplicate()
			if not repeatable: used[id] = true
			var fuel: Dictionary = state.fuel.duplicate()
			if fuel_key != "": fuel[fuel_key] = int(fuel.get(fuel_key, 0)) + 1
			var steps: Array = state.steps.duplicate()
			steps.append([row[0], row[1]])
			queue.append({"pool": next, "used": used, "fuel": fuel, "steps": steps,
				"rank": _distance(next, cost, extra, usage) + steps.size() * 0.05})
	return []

## Cheap optimistic bounds reject impossible X/colour probes before search.
static func _possible(actions: Array, pool: ManaPool, cost: ManaCost, extra: int, usage: Array) -> bool:
	var gains := {}
	var colour_sources := {}
	var converters := {}
	var feed_usage := _feed_usage(actions, usage)
	var available := pool._spendable(feed_usage)
	var total := 0
	for color in available: total += int(available[color])
	for row in actions:
		if not ManaPlanner.source_usable(row, feed_usage): continue
		var id: int = row[0].id
		var activation: ManaCost = row[8].cost if row.size() > 8 else null
		var repeatable: bool = row.size() > 8 and bool(row[8].repeatable)
		var fuel: int = row[8].get("fuel", 0) if row.size() > 8 else 0
		if repeatable and fuel == 0:
			converters[row[2]] = true
			continue
		var produced := 0
		var row_colors := {}
		for output in _outputs(row):
			if output[2] != "" and not feed_usage.has(output[2]): continue
			var quantity := int(output[1]) * maxi(1, fuel)
			produced += quantity
			row_colors[output[0]] = int(row_colors.get(output[0], 0)) + quantity
		for color in row_colors:
			if not colour_sources.has(color): colour_sources[color] = {}
			colour_sources[color][id] = maxi(int(colour_sources[color].get(id, 0)), int(row_colors[color]))
		var net := produced - (activation.mana_value() if activation != null else 0)
		gains[id] = maxi(int(gains.get(id, 0)), net)
	for id in gains: total += int(gains[id])
	if total < cost.mana_value() + extra: return false
	for color in cost.colored:
		if converters.has(color): continue
		var count := int(available.get(color, 0))
		for id in colour_sources.get(color, {}): count += int(colour_sources[color][id])
		if count < int(cost.colored[color]): return false
	return true

static func _distance(pool: ManaPool, cost: ManaCost, extra: int, usage: Array) -> float:
	var available := pool._spendable(usage)
	var missing := 0
	var total := 0
	for color in available: total += int(available[color])
	for color in cost.colored:
		missing += maxi(int(cost.colored[color]) - int(available.get(color, 0)), 0)
	return float(missing * 2 + maxi(cost.mana_value() + extra - total, 0))

## An artifact-activation-only output may feed a converter whose final
## output pays a spell. The optimistic pruning bound must allow that
## intermediate use; actual transitions still enforce each payment key.
static func _feed_usage(actions: Array, final_usage: Array) -> Array:
	var out := final_usage.duplicate()
	for row in actions:
		if row.size() <= 8: continue
		for key in row[8].get("cost_usage", []):
			if not out.has(key): out.append(key)
	return out

static func _outputs(row: Array) -> Array:
	return row[8].get("outputs", [[row[2], row[3], row[5]]]) if row.size() > 8 else [[row[2], row[3], row[5]]]

static func _key(state: Dictionary) -> String:
	var used: Array = state.used.keys()
	used.sort()
	# Preserve dictionary insertion order: it breaks generic-payment ties.
	return str([state.pool._mana, state.pool._restricted, used, state.fuel])
