extends CardScript
## School of the Unseen —  — Land (uncommon, all).
## Oracle: {T}: Add {C}.
##         {2}, {T}: Add one mana of any color.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("School of the Unseen", "", Mtg.CardType.LAND)
	c.oracle("{T}: Add {C}.\n{2}, {T}: Add one mana of any color.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
