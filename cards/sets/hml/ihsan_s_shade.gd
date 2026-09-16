extends CardScript
## Ihsan's Shade — {3}{B}{B}{B} — Legendary Creature — Shade Knight (uncommon, hml).
## Oracle: Protection from white
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Ihsan's Shade", "{3}{B}{B}{B}", Mtg.CardType.CREATURE)
	c.pt(5, 5)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["shade","knight"])
	c.with_protection_from(Mtg.ManaColor.W)
	c.oracle("Protection from white")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
