extends CardScript
## Zuran Orb — {0} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Zuran Orb", "{0}", Mtg.CardType.ARTIFACT)
	card.oracle("Sacrifice a land: You gain 2 life.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
