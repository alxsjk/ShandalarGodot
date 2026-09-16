class_name CounterMarkerEffect
extends EffectBase
## Put named counters on a target; counter stat changes are derived by the
## existing continuous-effects layer, not stored as temporary pumps.

var kind: String
var count: int

func _init(counter_kind: String, number := 1, spec: TargetSpec = null) -> void:
	kind = counter_kind
	count = number
	target_spec = spec if spec != null else TargetSpec.creature()
	ai_helpful = not kind.begins_with("-")

func resolve(game: MtgGame, _source: CardInstance, _controller: int,
		target: TargetRef, _x_value := 0) -> void:
	var inst := game.find_instance(target.instance_id)
	if inst != null and inst.zone == Mtg.Zone.BATTLEFIELD:
		game.add_counters(inst, kind, count)

func describe() -> String:
	return "put %d %s counter(s) on %s" % [count, kind, target_spec.description]
