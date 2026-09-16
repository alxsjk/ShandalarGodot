extends CardScript
## Rashka the Slayer — {3}{W}{W} — Legendary Creature — Human Archer (uncommon, hml).
## Oracle: Reach (This creature can block creatures with flying.)
##         Whenever Rashka blocks one or more black creatures, Rashka gets +1/+2 until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Rashka the Slayer", "{3}{W}{W}", Mtg.CardType.CREATURE)
	c.pt(3, 3)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["human","archer"])
	c.with_keywords([Mtg.Keyword.REACH])
	c.oracle("Reach (This creature can block creatures with flying.)\nWhenever Rashka blocks one or more black creatures, Rashka gets +1/+2 until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
