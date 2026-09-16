extends CardScript
## Martyrdom — {1}{W}{W} — Instant (common, all).
## Oracle: Until end of turn, target creature you control gains "{0}: The next 1 damage that would be dealt to target creature, planeswalker, or player this turn is dealt to this creature instead." Only you may activate this ability.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Martyrdom", "{1}{W}{W}", Mtg.CardType.INSTANT)
	c.oracle("Until end of turn, target creature you control gains \"{0}: The next 1 damage that would be dealt to target creature, planeswalker, or player this turn is dealt to this creature instead.\" Only you may activate this ability.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
