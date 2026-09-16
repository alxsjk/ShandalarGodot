extends CardScript
## Foresight — {1}{U} — Sorcery (common, all).
## Oracle: Search your library for three cards, exile them, then shuffle.
##         Draw a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Foresight", "{1}{U}", Mtg.CardType.SORCERY)
	c.oracle("Search your library for three cards, exile them, then shuffle.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
