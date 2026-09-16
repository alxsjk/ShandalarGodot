extends CardScript
## Venomous Breath — {3}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Venomous Breath", "{3}{G}", Mtg.CardType.INSTANT)
	card.oracle("Choose target creature. At this turn's next end of combat, destroy all creatures that blocked or were blocked by it this turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
