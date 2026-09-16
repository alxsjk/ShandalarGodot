extends CardScript
## Snow-Covered Mountain — no mana cost — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Snow-Covered Mountain", "", Mtg.CardType.LAND)
	card.with_supertypes(Mtg.Supertype.BASIC | Mtg.Supertype.SNOW)
	card.with_subtypes(["mountain"])
	card.oracle("({T}: Add {R}.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
