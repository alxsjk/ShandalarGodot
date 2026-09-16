extends CardScript
## Swamp Mosquito — {1}{B} — Creature — Insect (common, all).
## Oracle: Flying
##         Whenever this creature attacks and isn't blocked, defending player gets a poison counter. (A player with ten or more poison counters loses the game.)
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Swamp Mosquito", "{1}{B}", Mtg.CardType.CREATURE)
	c.pt(0, 1)
	c.with_subtypes(["insect"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying\nWhenever this creature attacks and isn't blocked, defending player gets a poison counter. (A player with ten or more poison counters loses the game.)")
	return load("res://cards/sets/all/_rules.gd").apply(c)
