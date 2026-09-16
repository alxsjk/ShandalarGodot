extends CardScript
## Mystic Compass — {2} — Artifact (uncommon, all).
## Oracle: {1}, {T}: Target land becomes the basic land type of your choice until end of turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Mystic Compass", "{2}", Mtg.CardType.ARTIFACT)
	c.oracle("{1}, {T}: Target land becomes the basic land type of your choice until end of turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
