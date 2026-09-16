extends CardScript
## Hungry Mist — {2}{G}{G} — Creature — Elemental (common, hml).
## Oracle: At the beginning of your upkeep, sacrifice this creature unless you pay {G}{G}.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Hungry Mist", "{2}{G}{G}", Mtg.CardType.CREATURE)
	c.pt(6, 2)
	c.with_subtypes(["elemental"])
	c.oracle("At the beginning of your upkeep, sacrifice this creature unless you pay {G}{G}.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
