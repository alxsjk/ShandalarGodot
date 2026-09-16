class_name SgTargetSpec
extends TargetSpec
## Server-authorized candidates translated to presentation-local references.
var candidates: Array[TargetRef] = []
var tokens: Array[String] = []


func legal_targets(_game: MtgGame, _source: CardInstance, _earlier: Array = []) -> Array[TargetRef]:
	return candidates.duplicate()


func refusal_reason(_game: MtgGame, ref: TargetRef, _source: CardInstance, _earlier: Array = []) -> String:
	return "" if token_for(ref) != "" else "Illegal target."


func token_for(ref: TargetRef) -> String:
	for i in candidates.size():
		if same(candidates[i], ref): return tokens[i]
	return ""


static func same(a: TargetRef, b: TargetRef) -> bool:
	return a.is_player == b.is_player and a.is_damage == b.is_damage and a.is_ability == b.is_ability \
		and a.player_id == b.player_id and a.instance_id == b.instance_id \
		and a.ability_id == b.ability_id and a.packet_id == b.packet_id
