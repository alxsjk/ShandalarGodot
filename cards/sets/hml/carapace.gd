extends CardScript
## Carapace — {G} — Enchantment — Aura (common, hml).
## Oracle: Enchant creature
##         Enchanted creature gets +0/+2.
##         Sacrifice this Aura: Regenerate enchanted creature.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Carapace", "{G}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nEnchanted creature gets +0/+2.\nSacrifice this Aura: Regenerate enchanted creature.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
