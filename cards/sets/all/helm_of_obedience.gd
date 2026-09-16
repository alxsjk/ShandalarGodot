extends CardScript
## Helm of Obedience — {4} — Artifact (rare, all).
## Oracle: {X}, {T}: Target opponent mills a card, then repeats this process until a creature card or X cards have been put into their graveyard this way, whichever comes first. If one or more creature cards were put into that graveyard this way, sacrifice this artifact and put one of them onto the battlefield under your control. X can't be 0.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Helm of Obedience", "{4}", Mtg.CardType.ARTIFACT)
	c.oracle("{X}, {T}: Target opponent mills a card, then repeats this process until a creature card or X cards have been put into their graveyard this way, whichever comes first. If one or more creature cards were put into that graveyard this way, sacrifice this artifact and put one of them onto the battlefield under your control. X can't be 0.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
