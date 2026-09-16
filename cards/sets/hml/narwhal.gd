extends CardScript
## Narwhal — {2}{U}{U} — Creature — Whale (rare, hml).
## Oracle: First strike, protection from red
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Narwhal", "{2}{U}{U}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["whale"])
	c.with_keywords([Mtg.Keyword.FIRST_STRIKE])
	c.with_protection_from(Mtg.ManaColor.R)
	c.oracle("First strike, protection from red")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
