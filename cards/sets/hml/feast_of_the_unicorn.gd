extends CardScript
## Feast of the Unicorn — {3}{B} — Enchantment — Aura (common, hml).
## Oracle: Enchant creature
##         Enchanted creature gets +4/+0.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Feast of the Unicorn", "{3}{B}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nEnchanted creature gets +4/+0.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
