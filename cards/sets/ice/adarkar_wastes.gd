extends CardScript
## Adarkar Wastes — no mana cost — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Adarkar Wastes", "", Mtg.CardType.LAND)
	card.oracle("{T}: Add {C}.\n{T}: Add {W} or {U}. This land deals 1 damage to you.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
