extends CardScript
## Kjeldoran Pride — {1}{W} — Enchantment — Aura (common, all).
## Oracle: Enchant creature
##         Enchanted creature gets +1/+2.
##         {2}{U}: Attach this Aura to target creature other than enchanted creature.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Kjeldoran Pride", "{1}{W}", Mtg.CardType.ENCHANTMENT)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature\nEnchanted creature gets +1/+2.\n{2}{U}: Attach this Aura to target creature other than enchanted creature.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
