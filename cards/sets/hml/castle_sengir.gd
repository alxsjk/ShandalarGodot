extends CardScript
## Castle Sengir —  — Land (uncommon, hml).
## Oracle: {T}: Add {C}.
##         {1}, {T}: Add {B}.
##         {2}, {T}: Add {U} or {R}.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Castle Sengir", "", Mtg.CardType.LAND)
	c.pt(0, 0)
	c.oracle("{T}: Add {C}.\n{1}, {T}: Add {B}.\n{2}, {T}: Add {U} or {R}.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
