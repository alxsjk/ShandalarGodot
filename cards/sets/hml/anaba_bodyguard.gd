extends CardScript
## Anaba Bodyguard — {3}{R} — Creature — Minotaur (common, hml).
## Oracle: First strike (This creature deals combat damage before creatures without first strike.)
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Anaba Bodyguard", "{3}{R}", Mtg.CardType.CREATURE)
	c.pt(2, 3)
	c.with_subtypes(["minotaur"])
	c.with_keywords([Mtg.Keyword.FIRST_STRIKE])
	c.oracle("First strike (This creature deals combat damage before creatures without first strike.)")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
