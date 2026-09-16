extends CardScript
## Exile — {2}{W} — Instant (rare, all).
## Oracle: Exile target nonwhite attacking creature. You gain life equal to its toughness.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Exile", "{2}{W}", Mtg.CardType.INSTANT)
	c.oracle("Exile target nonwhite attacking creature. You gain life equal to its toughness.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
