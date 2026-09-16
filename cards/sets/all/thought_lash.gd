extends CardScript
## Thought Lash — {2}{U}{U} — Enchantment (rare, all).
## Oracle: Cumulative upkeep—Exile the top card of your library. (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)
##         When a player doesn't pay this enchantment's cumulative upkeep, that player exiles all cards from their library.
##         Exile the top card of your library: Prevent the next 1 damage that would be dealt to you this turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Thought Lash", "{2}{U}{U}", Mtg.CardType.ENCHANTMENT)
	c.oracle("Cumulative upkeep—Exile the top card of your library. (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nWhen a player doesn't pay this enchantment's cumulative upkeep, that player exiles all cards from their library.\nExile the top card of your library: Prevent the next 1 damage that would be dealt to you this turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
