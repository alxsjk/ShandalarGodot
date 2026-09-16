extends CardScript
## Sol Grail — {3} — Artifact (uncommon, all).
## Oracle: As this artifact enters, choose a color.
##         {T}: Add one mana of the chosen color.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Sol Grail", "{3}", Mtg.CardType.ARTIFACT)
	c.oracle("As this artifact enters, choose a color.\n{T}: Add one mana of the chosen color.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
