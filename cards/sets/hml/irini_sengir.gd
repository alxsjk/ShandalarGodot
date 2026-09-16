extends CardScript
## Irini Sengir — {2}{B}{B} — Legendary Creature — Vampire Dwarf (uncommon, hml).
## Oracle: Green enchantment spells and white enchantment spells cost {2} more to cast.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Irini Sengir", "{2}{B}{B}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["vampire","dwarf"])
	c.oracle("Green enchantment spells and white enchantment spells cost {2} more to cast.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
