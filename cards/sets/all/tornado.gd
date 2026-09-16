extends CardScript
## Tornado — {4}{G} — Enchantment (rare, all).
## Oracle: Cumulative upkeep {G} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)
##         {2}{G}, Pay 3 life for each velocity counter on this enchantment: Destroy target permanent and put a velocity counter on this enchantment. Activate only once each turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Tornado", "{4}{G}", Mtg.CardType.ENCHANTMENT)
	c.oracle("Cumulative upkeep {G} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\n{2}{G}, Pay 3 life for each velocity counter on this enchantment: Destroy target permanent and put a velocity counter on this enchantment. Activate only once each turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
