extends CardScript
## Lat-Nam's Legacy — {1}{U} — Instant (common, all).
## Oracle: Shuffle a card from your hand into your library. If you do, draw two cards at the beginning of the next turn's upkeep.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Lat-Nam's Legacy", "{1}{U}", Mtg.CardType.INSTANT)
	c.oracle("Shuffle a card from your hand into your library. If you do, draw two cards at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
