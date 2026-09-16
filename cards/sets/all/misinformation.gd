extends CardScript
## Misinformation — {B} — Instant (uncommon, all).
## Oracle: Put up to three target cards from an opponent's graveyard on top of their library in any order.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Misinformation", "{B}", Mtg.CardType.INSTANT)
	c.oracle("Put up to three target cards from an opponent's graveyard on top of their library in any order.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
