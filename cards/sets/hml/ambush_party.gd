extends CardScript
## Ambush Party — {4}{R} — Creature — Human Rogue (common, hml).
## Oracle: First strike, haste
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Ambush Party", "{4}{R}", Mtg.CardType.CREATURE)
	c.pt(3, 1)
	c.with_subtypes(["human","rogue"])
	c.with_keywords([Mtg.Keyword.FIRST_STRIKE])
	c.with_keywords([Mtg.Keyword.HASTE])
	c.oracle("First strike, haste")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
