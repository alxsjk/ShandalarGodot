class_name SgPayment
extends RefCounted
## Referee-only payment estimates. One source enumeration per decision; no
## client simulation. X costs in this engine grow monotonically with X.

static func due(g: MtgGame, pid: int, card: CardInstance, kind: String, index: int, x: int, count := 1, mode := 0) -> Dictionary:
	return g.spell_payment(pid, card.data, x, count, card, mode) if kind == "spell" else g.ability_payment(pid, card, index, x)

static func budget(g: MtgGame, pid: int, card: CardInstance, kind: String, index: int, sources: Array, count := 1, mode := 0) -> int:
	var low := 0
	var high := 1000
	while low < high:
		var middle := (low + high + 1) / 2
		var cost := due(g, pid, card, kind, index, middle, count, mode)
		if g.players[pid].mana_pool.can_pay(cost.cost, cost.extra, cost.usage) \
			or not ManaPlanner.plan_from(sources, cost.cost, cost.extra, cost.usage).is_empty(): low = middle
		else: high = middle - 1
	return low


## Public affordance, not permission to cast. The real cast still validates
## timing, targets and every object cost. Include pitch modes and instance-
## scoped mana restrictions instead of pricing only the printed mana cost.
static func affordable(g: MtgGame, pid: int, card: CardInstance, potential := false) -> bool:
	for mode in maxi(1, card.data.modes.size()):
		var option := card.data.payment_option(mode)
		if int(option.get("life", 0)) > g.players[pid].life: continue
		if int(option.get("exile_color", 0)) != 0 and g.pitch_candidates(pid, card, mode).is_empty(): continue
		var cost := due(g, pid, card, "spell", 0, 0, 1, mode)
		var p := g.players[pid]
		if p.mana_pool.can_pay(cost.cost, cost.extra, cost.usage, p.mana_substitutions, p.any_color_spells > 0): return true
		if potential and not ManaPlanner.plan(g, pid, cost.cost, cost.extra, cost.usage).is_empty(): return true
	return false
