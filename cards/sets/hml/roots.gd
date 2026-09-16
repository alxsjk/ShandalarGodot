extends CardScript
## Roots — {3}{G} — Enchantment — Aura (uncommon, hml).
## Oracle: Enchant creature without flying
##         When this Aura enters, tap enchanted creature.
##         Enchanted creature doesn't untap during its controller's untap step.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Roots", "{3}{G}", Mtg.CardType.ENCHANTMENT)
	c.pt(0, 0)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature without flying\nWhen this Aura enters, tap enchanted creature.\nEnchanted creature doesn't untap during its controller's untap step.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
