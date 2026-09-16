extends CardScript
## Sea Sprite — {1}{U} — Creature — Faerie (uncommon, hml).
## Oracle: Flying, protection from red
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Sea Sprite", "{1}{U}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["faerie"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.with_protection_from(Mtg.ManaColor.R)
	c.oracle("Flying, protection from red")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
