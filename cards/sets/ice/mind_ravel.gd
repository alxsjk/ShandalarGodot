extends CardScript
## Mind Ravel — {2}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Mind Ravel", "{2}{B}", Mtg.CardType.SORCERY)
	card.oracle("Target player discards a card.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
