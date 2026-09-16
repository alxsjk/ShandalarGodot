extends CardScript
## Kjeldoran Elite Guard — {3}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Kjeldoran Elite Guard", "{3}{W}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["human","soldier"])
	card.oracle("{T}: Target creature gets +2/+2 until end of turn. When that creature leaves the battlefield this turn, sacrifice this creature. Activate only during combat.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
