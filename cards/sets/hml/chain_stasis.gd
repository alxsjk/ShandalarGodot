extends CardScript
## Chain Stasis — {U} — Instant (rare, hml).
## Oracle: You may tap or untap target creature. Then that creature's controller may pay {2}{U}. If the player does, they may copy this spell and may choose a new target for that copy.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Chain Stasis", "{U}", Mtg.CardType.INSTANT)
	c.pt(0, 0)
	c.oracle("You may tap or untap target creature. Then that creature's controller may pay {2}{U}. If the player does, they may copy this spell and may choose a new target for that copy.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
