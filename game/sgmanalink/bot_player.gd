class_name SgBotPlayer
extends RefCounted
## [QoL] Host-managed computer seats use the shipped engine players, not a
## coverage pilot. This adapter schedules their public-API actions; it does
## not change strategy, reveal hands to clients or grant client authority.

const LEVELS := ["Apprentice", "Magician", "Sorcerer", "Wizard"]


static func defaults() -> Dictionary:
	return {"level": 3, "unfair": false, "pace_ms": 350}


static func valid(value: Variant) -> bool:
	return value is Dictionary and SgProtocol.exact(value, ["level", "unfair", "pace_ms"]) \
		and SgProtocol.integer(value.level, 0, 3) and value.unfair is bool \
		and (not value.unfair or value.level == 3) and SgProtocol.integer(value.pace_ms, 50, 2000)


static func label(options: Dictionary) -> String:
	return "Unfair" if options.unfair else String(LEVELS[int(options.level)])


static func create(pid: int, options: Dictionary) -> AiPlayer:
	if not valid(options): return null
	if options.unfair: return UnfairPlayer.new(pid)
	var profiles := [AiProfile.apprentice(), AiProfile.magician(), AiProfile.sorcerer(), AiProfile.wizard()]
	return AiPlayer.new(pid, profiles[int(options.level)])


static func step(referee: SgPracticeMatch, pilot: AiPlayer) -> void:
	var state := referee.decision_state()
	if state.actor != pilot.pid or state.mode == "finished": return
	if state.mode == "opening":
		if not referee.order_chosen:
			# Same play-first policy as the local computer opponent.
			referee.act(pilot.pid, {"op": "order", "play": true})
		else:
			var redraw := referee.game.may_mulligan(pilot.pid) and pilot.choose_mulligan(referee.game, pilot.pid)
			referee.act(pilot.pid, {"op": "mulligan" if redraw else "keep"})
		return
	# AI choice/discard/damage policies answer synchronously through the
	# installed DecisionAgent. Never pass over an outstanding human question.
	if state.mode in ["choice", "discard", "damage"]: return
	pilot.act(referee.game)
