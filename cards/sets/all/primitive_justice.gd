extends CardScript
## Primitive Justice — {1}{R} — Sorcery (uncommon, all).
## Oracle: As an additional cost to cast this spell, you may pay {1}{R} and/or {1}{G} any number of times.
##         Destroy target artifact. For each additional {1}{R} you paid, destroy another target artifact. For each additional {1}{G} you paid, destroy another target artifact, and you gain 1 life.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Primitive Justice", "{1}{R}", Mtg.CardType.SORCERY)
	c.oracle("As an additional cost to cast this spell, you may pay {1}{R} and/or {1}{G} any number of times.\nDestroy target artifact. For each additional {1}{R} you paid, destroy another target artifact. For each additional {1}{G} you paid, destroy another target artifact, and you gain 1 life.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
