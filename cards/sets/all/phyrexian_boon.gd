extends CardScript
## Phyrexian Boon — {2}{B} — Enchantment — Aura (common, all).
## Oracle: Enchant creature
##         Enchanted creature gets +2/+1 as long as it's black. Otherwise, it gets -1/-2.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Phyrexian Boon", "{2}{B}", Mtg.CardType.ENCHANTMENT)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nEnchanted creature gets +2/+1 as long as it's black. Otherwise, it gets -1/-2.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
