extends CardScript
## Black Carriage — {3}{B}{B} — Creature — Horse (rare, hml).
## Oracle: Trample
##         This creature doesn't untap during your untap step.
##         Sacrifice a creature: Untap this creature. Activate only during your upkeep.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Black Carriage", "{3}{B}{B}", Mtg.CardType.CREATURE)
	c.pt(4, 4)
	c.with_subtypes(["horse"])
	c.with_keywords([Mtg.Keyword.TRAMPLE])
	c.oracle("Trample\nThis creature doesn't untap during your untap step.\nSacrifice a creature: Untap this creature. Activate only during your upkeep.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
