extends CardScript
## Heart of Yavimaya —  — Land (rare, all).
## Oracle: If this land would enter, sacrifice a Forest instead. If you do, put this land onto the battlefield. If you don't, put it into its owner's graveyard.
##         {T}: Add {G}.
##         {T}: Target creature gets +1/+1 until end of turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Heart of Yavimaya", "", Mtg.CardType.LAND)
	c.oracle("If this land would enter, sacrifice a Forest instead. If you do, put this land onto the battlefield. If you don't, put it into its owner's graveyard.\n{T}: Add {G}.\n{T}: Target creature gets +1/+1 until end of turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
