extends CardScript
## Blinking Spirit — {3}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Blinking Spirit", "{3}{W}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["spirit"])
	card.oracle("{0}: Return this creature to its owner's hand.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
