extends CardScript
## Dystopia — {1}{B}{B} — Enchantment (rare, all).
## Oracle: Cumulative upkeep—Pay 1 life. (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)
##         At the beginning of each player's upkeep, that player sacrifices a green or white permanent of their choice.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Dystopia", "{1}{B}{B}", Mtg.CardType.ENCHANTMENT)
	c.oracle("Cumulative upkeep—Pay 1 life. (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nAt the beginning of each player's upkeep, that player sacrifices a green or white permanent of their choice.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
