extends CardScript
## An-Zerrin Ruins — {2}{R}{R} — Enchantment (rare, hml).
## Oracle: As this enchantment enters, choose a creature type.
##         Creatures of the chosen type don't untap during their controllers' untap steps.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("An-Zerrin Ruins", "{2}{R}{R}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.oracle("As this enchantment enters, choose a creature type.\nCreatures of the chosen type don't untap during their controllers' untap steps.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
