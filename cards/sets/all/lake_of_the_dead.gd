extends CardScript
## Lake of the Dead —  — Land (rare, all).
## Oracle: If this land would enter, sacrifice a Swamp instead. If you do, put this land onto the battlefield. If you don't, put it into its owner's graveyard.
##         {T}: Add {B}.
##         {T}, Sacrifice a Swamp: Add {B}{B}{B}{B}.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Lake of the Dead", "", Mtg.CardType.LAND)
	c.oracle("If this land would enter, sacrifice a Swamp instead. If you do, put this land onto the battlefield. If you don't, put it into its owner's graveyard.\n{T}: Add {B}.\n{T}, Sacrifice a Swamp: Add {B}{B}{B}{B}.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
