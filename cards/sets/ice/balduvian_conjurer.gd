extends CardScript
## Balduvian Conjurer — {1}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Balduvian Conjurer", "{1}{U}", Mtg.CardType.CREATURE)
	card.pt(0, 2)
	card.with_subtypes(["human","wizard"])
	card.oracle("{T}: Target snow land becomes a 2/2 creature until end of turn. It's still a land.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
