extends CardScript
## Serra Bestiary — {W}{W} — Enchantment — Aura (common, hml).
## Oracle: Enchant creature
##         At the beginning of your upkeep, sacrifice this Aura unless you pay {W}{W}.
##         Enchanted creature can't attack or block, and its activated abilities with {T} in their costs can't be activated.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Serra Bestiary", "{W}{W}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nAt the beginning of your upkeep, sacrifice this Aura unless you pay {W}{W}.\nEnchanted creature can't attack or block, and its activated abilities with {T} in their costs can't be activated.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
