extends CardScript
## Willow Faerie — {1}{G} — Creature — Faerie (common, hml).
## Oracle: Flying
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Willow Faerie", "{1}{G}", Mtg.CardType.CREATURE)
	c.pt(1, 2)
	c.with_subtypes(["faerie"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
