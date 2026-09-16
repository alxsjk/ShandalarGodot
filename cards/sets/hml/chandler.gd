extends CardScript
## Chandler — {4}{R} — Legendary Creature — Human Rogue (common, hml).
## Oracle: {R}{R}{R}, {T}: Destroy target artifact creature.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Chandler", "{4}{R}", Mtg.CardType.CREATURE)
	c.pt(3, 3)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["human","rogue"])
	c.oracle("{R}{R}{R}, {T}: Destroy target artifact creature.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
