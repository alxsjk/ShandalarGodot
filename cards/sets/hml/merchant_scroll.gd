extends CardScript
## Merchant Scroll — {1}{U} — Sorcery (common, hml).
## Oracle: Search your library for a blue instant card, reveal that card, put it into your hand, then shuffle.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Merchant Scroll", "{1}{U}", Mtg.CardType.SORCERY)
	c.pt(0, 0)
	c.oracle("Search your library for a blue instant card, reveal that card, put it into your hand, then shuffle.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
