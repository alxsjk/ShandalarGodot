extends CardScript
## Dark Maze — {4}{U} — Creature — Wall (common, hml).
## Oracle: Defender (This creature can't attack.)
##         {0}: This creature can attack this turn as though it didn't have defender. Exile it at the beginning of the next end step.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Dark Maze", "{4}{U}", Mtg.CardType.CREATURE)
	c.pt(4, 5)
	c.with_subtypes(["wall"])
	c.with_keywords([Mtg.Keyword.DEFENDER])
	c.oracle("Defender (This creature can't attack.)\n{0}: This creature can attack this turn as though it didn't have defender. Exile it at the beginning of the next end step.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
