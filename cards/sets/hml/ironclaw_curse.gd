extends CardScript
## Ironclaw Curse — {R} — Enchantment — Aura (rare, hml).
## Oracle: Enchant creature
##         Enchanted creature gets -0/-1.
##         Enchanted creature can't block creatures with power equal to or greater than the enchanted creature's toughness.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Ironclaw Curse", "{R}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nEnchanted creature gets -0/-1.\nEnchanted creature can't block creatures with power equal to or greater than the enchanted creature's toughness.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
