extends CardScript
## Snow Hound — {2}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Snow Hound", "{2}{W}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["dog"])
	card.oracle("{1}, {T}: Return this creature and target green or blue creature you control to their owner's hand.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
