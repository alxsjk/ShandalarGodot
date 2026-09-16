extends CardScript
## Krovikan Sorcerer — {2}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Krovikan Sorcerer", "{2}{U}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","wizard","sorcerer"])
	card.oracle("{T}, Discard a nonblack card: Draw a card.\n{T}, Discard a black card: Draw two cards, then discard one of them.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
