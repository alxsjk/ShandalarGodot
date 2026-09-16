extends CardScript
## Aliban's Tower — {1}{R} — Instant (common, hml).
## Oracle: Target blocking creature gets +3/+1 until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Aliban's Tower", "{1}{R}", Mtg.CardType.INSTANT)
	c.pt(0, 0)
	c.oracle("Target blocking creature gets +3/+1 until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
