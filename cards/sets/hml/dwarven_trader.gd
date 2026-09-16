extends CardScript
## Dwarven Trader — {R} — Creature — Dwarf (common, hml).
## Oracle: (no rules text)
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Dwarven Trader", "{R}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["dwarf"])
	c.oracle("")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
