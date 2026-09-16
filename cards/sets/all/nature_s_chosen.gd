extends CardScript
## Nature's Chosen — {G} — Enchantment — Aura (uncommon, all).
## Oracle: Enchant creature you control
##         {0}: Untap enchanted creature. Activate only during your turn and only once each turn.
##         Tap enchanted creature: Untap target artifact, creature, or land. Activate only if enchanted creature is white and untapped and only once each turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Nature's Chosen", "{G}", Mtg.CardType.ENCHANTMENT)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature you control\n{0}: Untap enchanted creature. Activate only during your turn and only once each turn.\nTap enchanted creature: Untap target artifact, creature, or land. Activate only if enchanted creature is white and untapped and only once each turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
