class_name ChosenDiscardEffect
extends EffectBase
## The controller looks at a target opponent's eligible cards, chooses through
## that seat's DecisionAgent funnel, and makes the opponent discard the picks.

var count: int = 1
var exclude_lands: bool = false


func _init(p_count := 1) -> void:
	count = maxi(p_count, 0)
	target_spec = TargetSpec.opponent()


func nonland_only() -> ChosenDiscardEffect:
	exclude_lands = true
	return self


func candidates(game: MtgGame, target_player: int) -> Array[CardInstance]:
	var out: Array[CardInstance] = []
	for inst in game.players[target_player].hand:
		if exclude_lands and inst.data.is_land():
			continue
		out.append(inst)
	return out


func resolve(game: MtgGame, _source: CardInstance, controller: int,
		target: TargetRef, _x_value: int = 0) -> void:
	var choices := candidates(game, target.player_id)
	game.log_line("%s reveals the eligible cards in their hand" %
		game.players[target.player_id].player_name)
	var picked: Array[CardInstance] = []
	while picked.size() < count and not choices.is_empty():
		var card := game.agents[controller].choose_card(game, controller,
			choices, "Choose a card for target opponent to discard")
		if card == null or not choices.has(card):
			break
		picked.append(card)
		choices.erase(card)
	if not picked.is_empty():
		game.discard_cards(target.player_id, picked)


func describe() -> String:
	var amount := "a" if count == 1 else str(count)
	var kind := "chosen nonland card" if exclude_lands else "chosen card"
	return "target opponent discards %s %s" % [amount, kind]
