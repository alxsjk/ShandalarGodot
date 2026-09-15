extends CardScript
## Phantasmal Mount — {1}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Phantasmal Mount", "{1}{U}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["illusion","horse"])
	card.with_keywords([Mtg.Keyword.FLYING])
	card.oracle("Flying\n{T}: Target creature you control with toughness 2 or less gets +1/+1 and gains flying until end of turn. When this creature leaves the battlefield this turn, sacrifice that creature. When the creature leaves the battlefield this turn, sacrifice this creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
