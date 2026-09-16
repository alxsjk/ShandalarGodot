extends CardScript
## Ambush — {3}{R} — Instant (common, hml).
## Oracle: Blocking creatures gain first strike until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Ambush", "{3}{R}", Mtg.CardType.INSTANT)
	c.pt(0, 0)
	c.oracle("Blocking creatures gain first strike until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
