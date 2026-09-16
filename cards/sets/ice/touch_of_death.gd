extends CardScript
## Touch of Death — {2}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Touch of Death", "{2}{B}", Mtg.CardType.SORCERY)
	card.oracle("Touch of Death deals 1 damage to target player or planeswalker. You gain 1 life.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
