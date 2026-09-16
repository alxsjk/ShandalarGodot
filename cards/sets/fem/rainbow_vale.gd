extends CardScript
## Rainbow Vale — Land — (fem, rare)
## Oracle: {T}: Add one mana of any color. An opponent gains control of this land at the beginning of the next end step.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Rainbow Vale", "", Mtg.CardType.LAND)
	card.oracle("{T}: Add one mana of any color. An opponent gains control of this land at the beginning of the next end step.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
