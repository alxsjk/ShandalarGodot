class_name RandomHandDiscardEffect
extends EffectBase
## Random discard uses the game's RNG only, never AI inspection of a hand.

var count: int
var controller_mode := false

func _init(number := 1, self_discard := false) -> void:
	count = number
	controller_mode = self_discard
	if not self_discard:
		target_spec = TargetSpec.player()

func resolve(game: MtgGame, _source: CardInstance, controller: int,
		target: TargetRef, _x_value := 0) -> void:
	game.discard_random(controller if controller_mode else target.player_id, count)

func describe() -> String:
	return "%s discards %d cards at random" % ["you" if controller_mode else "target player", count]
