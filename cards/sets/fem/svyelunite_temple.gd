extends CardScript
## Svyelunite Temple — Land — (fem, uncommon)
## Oracle: This land enters tapped.
##         {T}: Add {U}.
##         {T}, Sacrifice this land: Add {U}{U}.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Svyelunite Temple", "", Mtg.CardType.LAND)
	card.oracle("This land enters tapped.\n{T}: Add {U}.\n{T}, Sacrifice this land: Add {U}{U}.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
