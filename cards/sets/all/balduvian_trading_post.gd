extends CardScript
## Balduvian Trading Post —  — Land (rare, all).
## Oracle: If this land would enter, sacrifice an untapped Mountain instead. If you do, put this land onto the battlefield. If you don't, put it into its owner's graveyard.
##         {T}: Add {C}{R}.
##         {1}, {T}: This land deals 1 damage to target attacking creature.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Balduvian Trading Post", "", Mtg.CardType.LAND)
	c.oracle("If this land would enter, sacrifice an untapped Mountain instead. If you do, put this land onto the battlefield. If you don't, put it into its owner's graveyard.\n{T}: Add {C}{R}.\n{1}, {T}: This land deals 1 damage to target attacking creature.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
