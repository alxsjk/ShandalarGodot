extends CardScript
## Shrink — {G} — Instant (common, hml).
## Oracle: Target creature gets -5/-0 until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Shrink", "{G}", Mtg.CardType.INSTANT)
	c.pt(0, 0)
	c.oracle("Target creature gets -5/-0 until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
