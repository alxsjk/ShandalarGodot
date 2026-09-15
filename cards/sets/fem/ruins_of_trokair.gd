extends CardScript
## Ruins of Trokair — Land — (fem, uncommon)
## Oracle: This land enters tapped.
##         {T}: Add {W}.
##         {T}, Sacrifice this land: Add {W}{W}.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Ruins of Trokair", "", Mtg.CardType.LAND)
	card.oracle("This land enters tapped.\n{T}: Add {W}.\n{T}, Sacrifice this land: Add {W}{W}.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
