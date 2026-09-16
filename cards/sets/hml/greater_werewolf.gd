extends CardScript
## Greater Werewolf — {4}{B} — Creature — Werewolf (common, hml).
## Oracle: At end of combat, put a -0/-2 counter on each creature blocking or blocked by this creature.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Greater Werewolf", "{4}{B}", Mtg.CardType.CREATURE)
	c.pt(2, 4)
	c.with_subtypes(["werewolf"])
	c.oracle("At end of combat, put a -0/-2 counter on each creature blocking or blocked by this creature.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
