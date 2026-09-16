extends CardScript
## Aysen Abbey —  — Land (uncommon, hml).
## Oracle: {T}: Add {C}.
##         {1}, {T}: Add {W}.
##         {2}, {T}: Add {G} or {U}.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Aysen Abbey", "", Mtg.CardType.LAND)
	c.pt(0, 0)
	c.oracle("{T}: Add {C}.\n{1}, {T}: Add {W}.\n{2}, {T}: Add {G} or {U}.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
