extends CardScript
## Sengir Bats — {1}{B}{B} — Creature — Bat (common, hml).
## Oracle: Flying
##         Whenever a creature dealt damage by this creature this turn dies, put a +1/+1 counter on this creature.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Sengir Bats", "{1}{B}{B}", Mtg.CardType.CREATURE)
	c.pt(1, 2)
	c.with_subtypes(["bat"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying\nWhenever a creature dealt damage by this creature this turn dies, put a +1/+1 counter on this creature.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
