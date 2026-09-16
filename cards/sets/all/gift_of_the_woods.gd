extends CardScript
## Gift of the Woods — {G} — Enchantment — Aura (common, all).
## Oracle: Enchant creature
##         Whenever enchanted creature blocks or becomes blocked, it gets +0/+3 until end of turn and you gain 1 life.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Gift of the Woods", "{G}", Mtg.CardType.ENCHANTMENT)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nWhenever enchanted creature blocks or becomes blocked, it gets +0/+3 until end of turn and you gain 1 life.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
