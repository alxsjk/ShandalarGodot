class_name CoinFlipLifeLossEffect
extends EffectBase
## A two-player coin wager: the flipper or their opponent loses a fraction of
## their current life. Used by bounded digital substitutes for subgame cards.

var numerator: int = 1
var denominator: int = 2


func _init(p_numerator := 1, p_denominator := 2) -> void:
	numerator = maxi(p_numerator, 0)
	denominator = maxi(p_denominator, 1)


## Printed "rounded up" life loss.
func loss_at(life: int) -> int:
	return (maxi(life, 0) * numerator + denominator - 1) / denominator


func resolve(game: MtgGame, _source: CardInstance, controller: int,
		_target: TargetRef, _x_value: int = 0) -> void:
	var loser := game.opponent_of(controller) if game.flip_coin(controller) \
		else controller
	game.adjust_life(loser, -loss_at(game.players[loser].life))


func describe() -> String:
	return "the coin-flip loser loses %d/%d of their life, rounded up" % [
		numerator, denominator]
