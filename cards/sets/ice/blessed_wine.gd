extends CardScript
## Blessed Wine — {1}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Blessed Wine", "{1}{W}", Mtg.CardType.INSTANT)
	card.oracle("You gain 1 life.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
