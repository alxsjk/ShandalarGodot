extends CardScript
## Funeral March — {1}{B}{B} — Enchantment — Aura (common, hml).
## Oracle: Enchant creature
##         When enchanted creature leaves the battlefield, its controller sacrifices a creature of their choice.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Funeral March", "{1}{B}{B}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nWhen enchanted creature leaves the battlefield, its controller sacrifices a creature of their choice.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
