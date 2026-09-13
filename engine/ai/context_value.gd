class_name AiContextValue
extends RefCounted
## Marginal public-board value of a static support creature. No departure
## triggers or future draws: this estimates support, not a removal spell.


static func of(game: MtgGame, card: CardInstance, profile: AiProfile) -> float:
	var flat := Evaluator.permanent_value(card, profile)
	if not profile.values_context or card.zone != Mtg.Zone.BATTLEFIELD \
			or not card.is_creature() or card.face_down \
			or card.data.static_abilities.is_empty():
		return flat
	var seat := card.controller_id
	var read := func() -> float: return _board(game, seat, profile)
	var before := float(read.call())
	return maxf(0.0, before - game.value_without_permanent(card, read))


static func _board(game: MtgGame, seat: int, profile: AiProfile) -> float:
	var value := 0.0
	for card in game.all_battlefield():
		if not card.is_creature() or card.cur_toughness <= 0: continue
		value += (1.0 if card.controller_id == seat else -1.0) \
			* Evaluator.permanent_value(card, profile)
	return value
