extends CardScript
## Ebony Rhino — {7} — Artifact Creature — Rhino (common, hml).
## Oracle: Trample
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Ebony Rhino", "{7}", Mtg.CardType.CREATURE | Mtg.CardType.ARTIFACT)
	c.pt(4, 5)
	c.with_subtypes(["rhino"])
	c.with_keywords([Mtg.Keyword.TRAMPLE])
	c.oracle("Trample")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
