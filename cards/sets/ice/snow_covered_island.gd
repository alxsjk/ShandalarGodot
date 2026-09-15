extends CardScript
## Snow-Covered Island — no mana cost — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Snow-Covered Island", "", Mtg.CardType.LAND)
	card.with_supertypes(Mtg.Supertype.BASIC | Mtg.Supertype.SNOW)
	card.with_subtypes(["island"])
	card.oracle("({T}: Add {U}.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
