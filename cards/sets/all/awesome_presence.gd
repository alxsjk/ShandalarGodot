extends CardScript
## Awesome Presence — {U} — Enchantment — Aura (common, all).
## Oracle: Enchant creature
##         Enchanted creature can't be blocked unless defending player pays {3} for each creature they control that's blocking it.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Awesome Presence", "{U}", Mtg.CardType.ENCHANTMENT)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nEnchanted creature can't be blocked unless defending player pays {3} for each creature they control that's blocking it.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
