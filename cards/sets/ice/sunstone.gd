extends CardScript
## Sunstone — {3} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Sunstone", "{3}", Mtg.CardType.ARTIFACT)
	card.oracle("{2}, Sacrifice a snow land: Prevent all combat damage that would be dealt this turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
