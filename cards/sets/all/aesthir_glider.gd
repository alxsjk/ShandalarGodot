extends CardScript
## Aesthir Glider — {3} — Artifact Creature — Bird Construct (common, all).
## Oracle: Flying
##         This creature can't block.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Aesthir Glider", "{3}", Mtg.CardType.CREATURE | Mtg.CardType.ARTIFACT)
	c.pt(2, 1)
	c.with_subtypes(["bird","construct"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying\nThis creature can't block.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
