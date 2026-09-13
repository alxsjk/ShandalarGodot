class_name AiActionPlanner
extends RefCounted
## [QoL] Bounded main-phase sequencing over already legal, useful actions.
## Input is own-card proposals and a resource feasibility predicate. No game,
## random source or hidden-zone data reaches this search. Unmodelled effects
## end a line; draws are never simulated against the actual library.

var nodes := 0
var budget := 96
var depth := 3
var _best: Array = []
var _score := -INF


func choose(proposals: Array, can_pay: Callable) -> Array:
	nodes = 0
	_best = []
	_score = -INF
	if proposals.is_empty(): return []
	var ordered := proposals.duplicate()
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["value"]) > float(b["value"]))
	# A guaranteed win takes precedence over adding up several ordinary plays.
	if float(ordered[0]["value"]) >= 900.0: return [ordered[0]]
	_best = [ordered[0]]
	_score = float(ordered[0]["value"])
	_walk(ordered.slice(0, 10), [], 0.0, can_pay)
	return _best.duplicate()


func _walk(proposals: Array, line: Array, score: float, can_pay: Callable) -> void:
	if nodes >= budget or line.size() >= depth: return
	for option in proposals:
		if nodes >= budget: return
		if line.any(func(p: Dictionary) -> bool: return p["id"] == option["id"]):
			continue
		var next := line.duplicate()
		next.append(option)
		nodes += 1
		if not can_pay.call(next): continue
		var next_score := score + float(option["value"]) * pow(0.95, line.size())
		if next_score > _score + 0.000001:
			_score = next_score
			_best = next
		if bool(option.get("independent", false)):
			_walk(proposals, next, next_score, can_pay)
