extends CardScript
## Kjeldoran Royal Guard — {3}{W}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Kjeldoran Royal Guard", "{3}{W}{W}", Mtg.CardType.CREATURE)
	card.pt(2, 5)
	card.with_subtypes(["human","soldier"])
	card.oracle("{T}: All combat damage that would be dealt to you by unblocked creatures this turn is dealt to this creature instead.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
