extends CardScript
## Lim-Dûl's Vault — {U}{B} — Instant (uncommon, all).
## Oracle: Look at the top five cards of your library. As many times as you choose, you may pay 1 life, put those cards on the bottom of your library in any order, then look at the top five cards of your library. Then shuffle and put the last cards you looked at this way on top in any order.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Lim-Dûl's Vault", "{U}{B}", Mtg.CardType.INSTANT)
	c.oracle("Look at the top five cards of your library. As many times as you choose, you may pay 1 life, put those cards on the bottom of your library in any order, then look at the top five cards of your library. Then shuffle and put the last cards you looked at this way on top in any order.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
