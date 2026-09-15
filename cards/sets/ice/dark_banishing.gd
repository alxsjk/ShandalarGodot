extends CardScript
## Dark Banishing — {2}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Dark Banishing", "{2}{B}", Mtg.CardType.INSTANT)
	card.oracle("Destroy target nonblack creature. It can't be regenerated.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
