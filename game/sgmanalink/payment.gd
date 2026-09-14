class_name SgPayment
extends RefCounted
## Referee-only payment estimates. One source enumeration per decision; no
## client simulation. X costs in this engine grow monotonically with X.

static func due(g: MtgGame, pid: int, card: CardInstance, kind: String, index: int, x: int, count := 1) -> Dictionary:
	return g.spell_payment(pid, card.data, x, count) if kind == "spell" else g.ability_payment(pid, card, index, x)

static func budget(g: MtgGame, pid: int, card: CardInstance, kind: String, index: int, sources: Array, count := 1) -> int:
	var low := 0
	var high := 1000
	while low < high:
		var middle := (low + high + 1) / 2
		var cost := due(g, pid, card, kind, index, middle, count)
		if g.players[pid].mana_pool.can_pay(cost.cost, cost.extra, cost.usage) \
			or not ManaPlanner.plan_from(sources, cost.cost, cost.extra, cost.usage).is_empty(): low = middle
		else: high = middle - 1
	return low
