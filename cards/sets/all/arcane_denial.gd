extends CardScript
## Arcane Denial — {1}{U} — Instant (common, all).
## Oracle: Counter target spell. Its controller may draw up to two cards at the beginning of the next turn's upkeep.
##         You draw a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Arcane Denial", "{1}{U}", Mtg.CardType.INSTANT)
	c.oracle("Counter target spell. Its controller may draw up to two cards at the beginning of the next turn's upkeep.\nYou draw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
