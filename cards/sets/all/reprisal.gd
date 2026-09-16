extends CardScript
## Reprisal — {1}{W} — Instant (common, all).
## Oracle: Destroy target creature with power 4 or greater. It can't be regenerated.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Reprisal", "{1}{W}", Mtg.CardType.INSTANT)
	c.oracle("Destroy target creature with power 4 or greater. It can't be regenerated.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
