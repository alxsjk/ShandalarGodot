extends CardScript
## Leaping Lizard — {1}{G}{G} — Creature — Lizard (common, hml).
## Oracle: {1}{G}: This creature gets -0/-1 and gains flying until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Leaping Lizard", "{1}{G}{G}", Mtg.CardType.CREATURE)
	c.pt(2, 3)
	c.with_subtypes(["lizard"])
	c.oracle("{1}{G}: This creature gets -0/-1 and gains flying until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
