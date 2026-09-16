extends CardScript
## Stench of Decay — {1}{B}{B} — Instant (common, all).
## Oracle: Nonartifact creatures get -1/-1 until end of turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Stench of Decay", "{1}{B}{B}", Mtg.CardType.INSTANT)
	c.oracle("Nonartifact creatures get -1/-1 until end of turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
