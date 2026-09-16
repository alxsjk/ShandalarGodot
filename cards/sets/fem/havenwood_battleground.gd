extends CardScript
## Havenwood Battleground — Land — (fem, uncommon)
## Oracle: This land enters tapped.
##         {T}: Add {G}.
##         {T}, Sacrifice this land: Add {G}{G}.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Havenwood Battleground", "", Mtg.CardType.LAND)
	card.oracle("This land enters tapped.\n{T}: Add {G}.\n{T}, Sacrifice this land: Add {G}{G}.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
