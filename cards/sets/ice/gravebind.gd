extends CardScript
## Gravebind — {B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Gravebind", "{B}", Mtg.CardType.INSTANT)
	card.oracle("Target creature can't be regenerated this turn.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
