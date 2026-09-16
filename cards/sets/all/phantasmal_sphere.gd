extends CardScript
## Phantasmal Sphere — {1}{U} — Creature — Illusion (rare, all).
## Oracle: Flying
##         At the beginning of your upkeep, put a +1/+1 counter on this creature, then sacrifice this creature unless you pay {1} for each +1/+1 counter on it.
##         When this creature leaves the battlefield, target opponent creates an X/X blue Orb creature token with flying, where X is the number of +1/+1 counters on this creature.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Phantasmal Sphere", "{1}{U}", Mtg.CardType.CREATURE)
	c.pt(0, 1)
	c.with_subtypes(["illusion"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying\nAt the beginning of your upkeep, put a +1/+1 counter on this creature, then sacrifice this creature unless you pay {1} for each +1/+1 counter on it.\nWhen this creature leaves the battlefield, target opponent creates an X/X blue Orb creature token with flying, where X is the number of +1/+1 counters on this creature.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
