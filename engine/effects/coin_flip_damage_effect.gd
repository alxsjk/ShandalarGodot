class_name CoinFlipDamageEffect
extends EffectBase
## Flip independently for each chosen target; a won flip deals damage and
## may tap a survivor. Randomness uses MtgGame.flip_coin, so seeded games are
## reproducible and every outcome is logged through the shared coin mechanic.

var amount: int
var tap_survivors: bool = false


func _init(p_amount: int, p_tap_survivors := false) -> void:
	amount = maxi(p_amount, 0)
	tap_survivors = p_tap_survivors
	target_spec = TargetSpec.creature()


func target_one_or_more() -> CoinFlipDamageEffect:
	one_or_more()
	return self


## Bounded digital-dexterity vocabulary: choose one or two targets.
func target_one_or_two() -> CoinFlipDamageEffect:
	target_min = 1
	target_max = 2
	return self


func resolve_multi(game: MtgGame, source: CardInstance, controller: int,
		targets: Array, _x_value: int = 0) -> void:
	for target in targets:
		if not game.flip_coin(controller):
			continue
		game.deal_damage(source, target, amount)
		if not tap_survivors:
			continue
		var survivor := game.find_instance(target.instance_id)
		if survivor != null and survivor.zone == Mtg.Zone.BATTLEFIELD:
			game.tap_permanent(survivor)


func describe() -> String:
	var tail := ", then taps each survivor" if tap_survivors else ""
	return "flips for each target; wins deal %d damage%s" % [amount, tail]
