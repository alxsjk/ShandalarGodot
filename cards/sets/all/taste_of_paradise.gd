extends CardScript
## Taste of Paradise — {3}{G} — Sorcery (common, all).
## Oracle: As an additional cost to cast this spell, you may pay {1}{G} any number of times.
##         You gain 3 life plus an additional 3 life for each additional {1}{G} you paid.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Taste of Paradise", "{3}{G}", Mtg.CardType.SORCERY)
	c.oracle("As an additional cost to cast this spell, you may pay {1}{G} any number of times.\nYou gain 3 life plus an additional 3 life for each additional {1}{G} you paid.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
