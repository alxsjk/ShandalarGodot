extends CardScript
## Storm Crow — {1}{U} — Creature — Bird (common, all).
## Oracle: Flying (This creature can't be blocked except by creatures with flying or reach.)
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Storm Crow", "{1}{U}", Mtg.CardType.CREATURE)
	c.pt(1, 2)
	c.with_subtypes(["bird"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying (This creature can't be blocked except by creatures with flying or reach.)")
	return load("res://cards/sets/all/_rules.gd").apply(c)
