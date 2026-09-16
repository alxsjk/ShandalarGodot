extends CardScript
## Koskun Keep —  — Land (uncommon, hml).
## Oracle: {T}: Add {C}.
##         {1}, {T}: Add {R}.
##         {2}, {T}: Add {B} or {G}.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Koskun Keep", "", Mtg.CardType.LAND)
	c.pt(0, 0)
	c.oracle("{T}: Add {C}.\n{1}, {T}: Add {R}.\n{2}, {T}: Add {B} or {G}.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
