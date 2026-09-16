extends CardScript
## Wizards' School —  — Land (uncommon, hml).
## Oracle: {T}: Add {C}.
##         {1}, {T}: Add {U}.
##         {2}, {T}: Add {W} or {B}.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Wizards' School", "", Mtg.CardType.LAND)
	c.pt(0, 0)
	c.oracle("{T}: Add {C}.\n{1}, {T}: Add {U}.\n{2}, {T}: Add {W} or {B}.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
