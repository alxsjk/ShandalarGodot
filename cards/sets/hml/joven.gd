extends CardScript
## Joven — {3}{R}{R} — Legendary Creature — Human Rogue (common, hml).
## Oracle: {R}{R}{R}, {T}: Destroy target noncreature artifact.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Joven", "{3}{R}{R}", Mtg.CardType.CREATURE)
	c.pt(3, 3)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["human","rogue"])
	c.oracle("{R}{R}{R}, {T}: Destroy target noncreature artifact.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
