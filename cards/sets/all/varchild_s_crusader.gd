extends CardScript
## Varchild's Crusader — {3}{R} — Creature — Human Knight (common, all).
## Oracle: {0}: This creature can't be blocked this turn except by Walls. Sacrifice this creature at the beginning of the next end step.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Varchild's Crusader", "{3}{R}", Mtg.CardType.CREATURE)
	c.pt(3, 2)
	c.with_subtypes(["human","knight"])
	c.oracle("{0}: This creature can't be blocked this turn except by Walls. Sacrifice this creature at the beginning of the next end step.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
