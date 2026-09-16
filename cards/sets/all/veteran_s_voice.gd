extends CardScript
## Veteran's Voice — {R} — Enchantment — Aura (common, all).
## Oracle: Enchant creature you control
##         Tap enchanted creature: Target creature other than the creature tapped this way gets +2/+1 until end of turn. Activate only if enchanted creature is untapped.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Veteran's Voice", "{R}", Mtg.CardType.ENCHANTMENT)
	c.with_subtypes(["aura"])
	c.oracle("Enchant creature you control\nTap enchanted creature: Target creature other than the creature tapped this way gets +2/+1 until end of turn. Activate only if enchanted creature is untapped.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
