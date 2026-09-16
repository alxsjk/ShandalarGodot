extends CardScript
## Soldevi Digger — {2} — Artifact (rare, all).
## Oracle: {2}: Put the top card of your graveyard on the bottom of your library.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Soldevi Digger", "{2}", Mtg.CardType.ARTIFACT)
	c.oracle("{2}: Put the top card of your graveyard on the bottom of your library.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
