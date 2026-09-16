extends CardScript
## Ashnod's Cylix — {2} — Artifact (rare, all).
## Oracle: {3}, {T}: Target player looks at the top three cards of their library, puts one of them back on top of their library, then exiles the rest.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Ashnod's Cylix", "{2}", Mtg.CardType.ARTIFACT)
	c.oracle("{3}, {T}: Target player looks at the top three cards of their library, puts one of them back on top of their library, then exiles the rest.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
