extends CardScript
## Flare — {2}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Flare", "{2}{R}", Mtg.CardType.INSTANT)
	card.oracle("Flare deals 1 damage to any target.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
