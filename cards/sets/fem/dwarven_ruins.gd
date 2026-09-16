extends CardScript
## Dwarven Ruins — Land — (fem, uncommon)
## Oracle: This land enters tapped.
##         {T}: Add {R}.
##         {T}, Sacrifice this land: Add {R}{R}.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Dwarven Ruins", "", Mtg.CardType.LAND)
	card.oracle("This land enters tapped.\n{T}: Add {R}.\n{T}, Sacrifice this land: Add {R}{R}.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
