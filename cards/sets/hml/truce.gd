extends CardScript
## Truce — {2}{W} — Instant (rare, hml).
## Oracle: Each player may draw up to two cards. For each card less than two a player draws this way, that player gains 2 life.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Truce", "{2}{W}", Mtg.CardType.INSTANT)
	c.pt(0, 0)
	c.oracle("Each player may draw up to two cards. For each card less than two a player draws this way, that player gains 2 life.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
