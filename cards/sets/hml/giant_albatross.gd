extends CardScript
## Giant Albatross — {1}{U} — Creature — Bird (common, hml).
## Oracle: Flying
##         When this creature dies, you may pay {1}{U}. If you do, for each creature that dealt damage to this creature this turn, destroy that creature unless its controller pays 2 life. A creature destroyed this way can't be regenerated.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Giant Albatross", "{1}{U}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["bird"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying\nWhen this creature dies, you may pay {1}{U}. If you do, for each creature that dealt damage to this creature this turn, destroy that creature unless its controller pays 2 life. A creature destroyed this way can't be regenerated.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
