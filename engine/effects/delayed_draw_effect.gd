class_name DelayedDrawEffect
extends EffectBase
## Ice Age's slow cantrip. The recipient is fixed at resolution, and the
## next TURN's upkeep is used even if this resolves during an upkeep.
## A fizzled targeted spell never schedules its trailing draw effect.

var amount := 1

func _init(count := 1) -> void:
	amount = count
	ai_helpful = true

func resolve(game: MtgGame, source: CardInstance, controller: int,
		_target: TargetRef, _x_value := 0) -> void:
	game.schedule_delayed_trigger(TriggeredAbility.new(Mtg.EventType.UPKEEP_START,
		_draw, describe(), _next_turn.bind(game.turn_number)), controller, source,
		false, {"recipient": controller, "count": amount})

static func _next_turn(g: MtgGame, _source: CardInstance, _event: GameEvent, after_turn: int) -> bool:
	return g.turn_number > after_turn

static func _draw(g: MtgGame, _source: CardInstance, _event: GameEvent) -> void:
	var memory: Dictionary = g.current_delayed().get("memory", {})
	g.draw_cards(int(memory.recipient), int(memory.count))

func describe() -> String:
	return "draw %d card(s) at the beginning of the next turn's upkeep" % amount
