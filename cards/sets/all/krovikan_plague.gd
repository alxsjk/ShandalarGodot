extends CardScript
## Krovikan Plague — {2}{B} — Enchantment — Aura (uncommon, all).
## Oracle: Enchant non-Wall creature you control
##         When this Aura enters, draw a card at the beginning of the next turn's upkeep.
##         Tap enchanted creature: This Aura deals 1 damage to any target. Put a -0/-1 counter on enchanted creature. Activate only if enchanted creature is untapped.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Krovikan Plague", "{2}{B}", Mtg.CardType.ENCHANTMENT)
	c.with_subtypes(["aura"])
	c.oracle("Enchant non-Wall creature you control\nWhen this Aura enters, draw a card at the beginning of the next turn's upkeep.\nTap enchanted creature: This Aura deals 1 damage to any target. Put a -0/-1 counter on enchanted creature. Activate only if enchanted creature is untapped.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
