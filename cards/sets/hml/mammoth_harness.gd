extends CardScript
## Mammoth Harness — {3}{G} — Enchantment — Aura (rare, hml).
## Oracle: Enchant creature
##         Enchanted creature loses flying.
##         Whenever enchanted creature blocks or becomes blocked by a creature, the other creature gains first strike until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Mammoth Harness", "{3}{G}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nEnchanted creature loses flying.\nWhenever enchanted creature blocks or becomes blocked by a creature, the other creature gains first strike until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
