extends CardScript
## False Demise — {2}{U} — Enchantment — Aura (common, all).
## Oracle: Enchant creature
##         When enchanted creature dies, return that card to the battlefield under your control.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("False Demise", "{2}{U}", Mtg.CardType.ENCHANTMENT)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nWhen enchanted creature dies, return that card to the battlefield under your control.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
