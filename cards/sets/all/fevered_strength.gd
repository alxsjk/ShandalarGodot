extends CardScript
## Fevered Strength — {2}{B} — Instant (common, all).
## Oracle: Target creature gets +2/+0 until end of turn.
##         Draw a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Fevered Strength", "{2}{B}", Mtg.CardType.INSTANT)
	c.oracle("Target creature gets +2/+0 until end of turn.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
