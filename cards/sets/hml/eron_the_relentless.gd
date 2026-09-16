extends CardScript
## Eron the Relentless — {3}{R}{R} — Legendary Creature — Human Rogue (uncommon, hml).
## Oracle: Haste
##         {R}{R}{R}: Regenerate Eron.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Eron the Relentless", "{3}{R}{R}", Mtg.CardType.CREATURE)
	c.pt(5, 2)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["human","rogue"])
	c.with_keywords([Mtg.Keyword.HASTE])
	c.oracle("Haste\n{R}{R}{R}: Regenerate Eron.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
