extends CardScript
## Floodwater Dam — {3} — Artifact (rare, all).
## Oracle: {X}{X}{1}, {T}: Tap X target lands.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Floodwater Dam", "{3}", Mtg.CardType.ARTIFACT)
	c.oracle("{X}{X}{1}, {T}: Tap X target lands.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
