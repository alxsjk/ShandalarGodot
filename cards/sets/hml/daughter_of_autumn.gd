extends CardScript
## Daughter of Autumn — {2}{G}{G} — Legendary Creature — Avatar (rare, hml).
## Oracle: {W}: The next 1 damage that would be dealt to target white creature this turn is dealt to Daughter of Autumn instead.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Daughter of Autumn", "{2}{G}{G}", Mtg.CardType.CREATURE)
	c.pt(2, 4)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["avatar"])
	c.oracle("{W}: The next 1 damage that would be dealt to target white creature this turn is dealt to Daughter of Autumn instead.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
