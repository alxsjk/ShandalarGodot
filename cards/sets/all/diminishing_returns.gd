extends CardScript
## Diminishing Returns — {2}{U}{U} — Sorcery (rare, all).
## Oracle: Each player shuffles their hand and graveyard into their library. You exile the top ten cards of your library. Then each player draws up to seven cards.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Diminishing Returns", "{2}{U}{U}", Mtg.CardType.SORCERY)
	c.oracle("Each player shuffles their hand and graveyard into their library. You exile the top ten cards of your library. Then each player draws up to seven cards.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
