extends CardScript
## Casting of Bones — {2}{B} — Enchantment — Aura (common, all).
## Oracle: Enchant creature
##         When enchanted creature dies, draw three cards, then discard one of them.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Casting of Bones", "{2}{B}", Mtg.CardType.ENCHANTMENT)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nWhen enchanted creature dies, draw three cards, then discard one of them.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
