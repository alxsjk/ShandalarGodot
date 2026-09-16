extends CardScript
## Sheltered Valley —  — Land (rare, all).
## Oracle: If this land would enter, instead sacrifice each other permanent named Sheltered Valley you control, then put this land onto the battlefield.
##         At the beginning of your upkeep, if you control three or fewer lands, you gain 1 life.
##         {T}: Add {C}.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Sheltered Valley", "", Mtg.CardType.LAND)
	c.oracle("If this land would enter, instead sacrifice each other permanent named Sheltered Valley you control, then put this land onto the battlefield.\nAt the beginning of your upkeep, if you control three or fewer lands, you gain 1 life.\n{T}: Add {C}.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
