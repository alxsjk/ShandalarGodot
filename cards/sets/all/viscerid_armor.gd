extends CardScript
## Viscerid Armor — {1}{U} — Enchantment — Aura (common, all).
## Oracle: Enchant creature
##         Enchanted creature gets +1/+1.
##         {1}{U}: Return this Aura to its owner's hand.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Viscerid Armor", "{1}{U}", Mtg.CardType.ENCHANTMENT)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nEnchanted creature gets +1/+1.\n{1}{U}: Return this Aura to its owner's hand.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
