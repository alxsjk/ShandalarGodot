extends CardScript
## Tidal Control — {1}{U}{U} — Enchantment (rare, all).
## Oracle: Cumulative upkeep {2} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)
##         Pay 2 life or {2}: Counter target red or green spell. Any player may activate this ability.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Tidal Control", "{1}{U}{U}", Mtg.CardType.ENCHANTMENT)
	c.oracle("Cumulative upkeep {2} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nPay 2 life or {2}: Counter target red or green spell. Any player may activate this ability.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
