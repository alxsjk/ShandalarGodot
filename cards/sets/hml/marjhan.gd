extends CardScript
## Marjhan — {5}{U}{U} — Creature — Serpent (rare, hml).
## Oracle: This creature doesn't untap during your untap step.
##         {U}{U}, Sacrifice a creature: Untap this creature. Activate only during your upkeep.
##         This creature can't attack unless defending player controls an Island.
##         {U}{U}: This creature gets -1/-0 until end of turn and deals 1 damage to target attacking creature without flying.
##         When you control no Islands, sacrifice this creature.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Marjhan", "{5}{U}{U}", Mtg.CardType.CREATURE)
	c.pt(8, 8)
	c.with_subtypes(["serpent"])
	c.oracle("This creature doesn't untap during your untap step.\n{U}{U}, Sacrifice a creature: Untap this creature. Activate only during your upkeep.\nThis creature can't attack unless defending player controls an Island.\n{U}{U}: This creature gets -1/-0 until end of turn and deals 1 damage to target attacking creature without flying.\nWhen you control no Islands, sacrifice this creature.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
