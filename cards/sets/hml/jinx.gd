extends CardScript
## Jinx — {1}{U} — Instant (common, hml).
## Oracle: Target land becomes the basic land type of your choice until end of turn.
##         Draw a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Jinx", "{1}{U}", Mtg.CardType.INSTANT)
	c.pt(0, 0)
	c.oracle("Target land becomes the basic land type of your choice until end of turn.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
