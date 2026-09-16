extends CardScript
## Memory Lapse — {1}{U} — Instant (common, hml).
## Oracle: Counter target spell. If that spell is countered this way, put it on top of its owner's library instead of into that player's graveyard.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Memory Lapse", "{1}{U}", Mtg.CardType.INSTANT)
	c.pt(0, 0)
	c.oracle("Counter target spell. If that spell is countered this way, put it on top of its owner's library instead of into that player's graveyard.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
