extends CardScript
## Foul Familiar — {2}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Foul Familiar", "{2}{B}", Mtg.CardType.CREATURE)
	card.pt(3, 1)
	card.with_subtypes(["spirit"])
	card.oracle("This creature can't block.\n{B}, Pay 1 life: Return this creature to its owner's hand.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
