extends CardScript
## Ritual of the Machine — {2}{B}{B} — Sorcery (rare, all).
## Oracle: As an additional cost to cast this spell, sacrifice a creature.
##         Gain control of target nonartifact, nonblack creature.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Ritual of the Machine", "{2}{B}{B}", Mtg.CardType.SORCERY)
	c.oracle("As an additional cost to cast this spell, sacrifice a creature.\nGain control of target nonartifact, nonblack creature.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
