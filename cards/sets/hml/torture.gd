extends CardScript
## Torture — {B} — Enchantment — Aura (common, hml).
## Oracle: Enchant creature
##         {1}{B}: Put a -1/-1 counter on enchanted creature.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Torture", "{B}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\n{1}{B}: Put a -1/-1 counter on enchanted creature.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
