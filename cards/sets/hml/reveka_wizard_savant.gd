extends CardScript
## Reveka, Wizard Savant — {2}{U}{U} — Legendary Creature — Dwarf Wizard (rare, hml).
## Oracle: {T}: Reveka deals 2 damage to any target and doesn't untap during your next untap step.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Reveka, Wizard Savant", "{2}{U}{U}", Mtg.CardType.CREATURE)
	c.pt(0, 1)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["dwarf","wizard"])
	c.oracle("{T}: Reveka deals 2 damage to any target and doesn't untap during your next untap step.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
