extends CardScript
## Splintering Wind — {2}{G}{G} — Enchantment (rare, all).
## Oracle: {2}{G}: This enchantment deals 1 damage to target creature. Create a 1/1 green Splinter creature token. It has flying and "Cumulative upkeep {G}." When it leaves the battlefield, it deals 1 damage to you and each creature you control. (At the beginning of its controller's upkeep, that player puts an age counter on it, then sacrifices it unless they pay its upkeep cost for each age counter on it.)
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Splintering Wind", "{2}{G}{G}", Mtg.CardType.ENCHANTMENT)
	c.oracle("{2}{G}: This enchantment deals 1 damage to target creature. Create a 1/1 green Splinter creature token. It has flying and \"Cumulative upkeep {G}.\" When it leaves the battlefield, it deals 1 damage to you and each creature you control. (At the beginning of its controller's upkeep, that player puts an age counter on it, then sacrifices it unless they pay its upkeep cost for each age counter on it.)")
	return load("res://cards/sets/all/_rules.gd").apply(c)
