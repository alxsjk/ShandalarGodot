extends CardScript
## Bestial Fury — {2}{R} — Enchantment — Aura (common, all).
## Oracle: Enchant creature
##         When this Aura enters, draw a card at the beginning of the next turn's upkeep.
##         Whenever enchanted creature becomes blocked, it gets +4/+0 and gains trample until end of turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Bestial Fury", "{2}{R}", Mtg.CardType.ENCHANTMENT)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nWhen this Aura enters, draw a card at the beginning of the next turn's upkeep.\nWhenever enchanted creature becomes blocked, it gets +4/+0 and gains trample until end of turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
