extends CardScript
## Silver Erne — {3}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Silver Erne", "{3}{U}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["bird"])
	card.with_keywords([Mtg.Keyword.FLYING, Mtg.Keyword.TRAMPLE])
	card.oracle("Flying, trample")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
