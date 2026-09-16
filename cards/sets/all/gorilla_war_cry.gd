extends CardScript
## Gorilla War Cry — {1}{R} — Instant (common, all).
## Oracle: Cast this spell only during combat before blockers are declared.
##         All creatures gain menace until end of turn. (They can't be blocked except by two or more creatures.)
##         Draw a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Gorilla War Cry", "{1}{R}", Mtg.CardType.INSTANT)
	c.oracle("Cast this spell only during combat before blockers are declared.\nAll creatures gain menace until end of turn. (They can't be blocked except by two or more creatures.)\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
