extends CardScript
## Soldevi Excavations —  — Land (rare, all).
## Oracle: If this land would enter, sacrifice an untapped Island instead. If you do, put this land onto the battlefield. If you don't, put it into its owner's graveyard.
##         {T}: Add {C}{U}.
##         {1}, {T}: Scry 1.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Soldevi Excavations", "", Mtg.CardType.LAND)
	c.oracle("If this land would enter, sacrifice an untapped Island instead. If you do, put this land onto the battlefield. If you don't, put it into its owner's graveyard.\n{T}: Add {C}{U}.\n{1}, {T}: Scry 1.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
