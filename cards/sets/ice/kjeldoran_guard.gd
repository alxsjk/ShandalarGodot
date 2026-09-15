extends CardScript
## Kjeldoran Guard — {1}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Kjeldoran Guard", "{1}{W}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","soldier"])
	card.oracle("{T}: Target creature gets +1/+1 until end of turn. When that creature leaves the battlefield this turn, sacrifice this creature. Activate only during combat and only if defending player controls no snow lands.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
