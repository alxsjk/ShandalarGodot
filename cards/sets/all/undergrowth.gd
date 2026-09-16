extends CardScript
## Undergrowth — {G} — Instant (common, all).
## Oracle: As an additional cost to cast this spell, you may pay {2}{R}.
##         Prevent all combat damage that would be dealt this turn. If this spell's additional cost was paid, this effect doesn't affect combat damage that would be dealt by red creatures.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Undergrowth", "{G}", Mtg.CardType.INSTANT)
	c.oracle("As an additional cost to cast this spell, you may pay {2}{R}.\nPrevent all combat damage that would be dealt this turn. If this spell's additional cost was paid, this effect doesn't affect combat damage that would be dealt by red creatures.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
