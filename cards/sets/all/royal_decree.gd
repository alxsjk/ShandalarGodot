extends CardScript
## Royal Decree — {2}{W}{W} — Enchantment (rare, all).
## Oracle: Cumulative upkeep {W} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)
##         Whenever a Swamp, Mountain, black permanent, or red permanent becomes tapped, this enchantment deals 1 damage to that permanent's controller.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Royal Decree", "{2}{W}{W}", Mtg.CardType.ENCHANTMENT)
	c.oracle("Cumulative upkeep {W} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nWhenever a Swamp, Mountain, black permanent, or red permanent becomes tapped, this enchantment deals 1 damage to that permanent's controller.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
