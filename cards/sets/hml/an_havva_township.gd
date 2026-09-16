extends CardScript
## An-Havva Township —  — Land (uncommon, hml).
## Oracle: {T}: Add {C}.
##         {1}, {T}: Add {G}.
##         {2}, {T}: Add {R} or {W}.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("An-Havva Township", "", Mtg.CardType.LAND)
	c.pt(0, 0)
	c.oracle("{T}: Add {C}.\n{1}, {T}: Add {G}.\n{2}, {T}: Add {R} or {W}.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
