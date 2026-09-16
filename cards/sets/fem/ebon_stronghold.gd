extends CardScript
## Ebon Stronghold — Land — (fem, uncommon)
## Oracle: This land enters tapped.
##         {T}: Add {B}.
##         {T}, Sacrifice this land: Add {B}{B}.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Ebon Stronghold", "", Mtg.CardType.LAND)
	card.oracle("This land enters tapped.\n{T}: Add {B}.\n{T}, Sacrifice this land: Add {B}{B}.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
