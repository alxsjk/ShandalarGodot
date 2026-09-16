extends CardScript
## Kjeldoran Outpost —  — Land (rare, all).
## Oracle: If this land would enter, sacrifice a Plains instead. If you do, put this land onto the battlefield. If you don't, put it into its owner's graveyard.
##         {T}: Add {W}.
##         {1}{W}, {T}: Create a 1/1 white Soldier creature token.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Kjeldoran Outpost", "", Mtg.CardType.LAND)
	c.oracle("If this land would enter, sacrifice a Plains instead. If you do, put this land onto the battlefield. If you don't, put it into its owner's graveyard.\n{T}: Add {W}.\n{1}{W}, {T}: Create a 1/1 white Soldier creature token.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
