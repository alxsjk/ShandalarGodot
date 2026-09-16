extends CardScript
## Shield Sphere — {0} — Artifact Creature — Wall (uncommon, all).
## Oracle: Defender
##         Whenever this creature blocks, put a -0/-1 counter on it.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Shield Sphere", "{0}", Mtg.CardType.CREATURE | Mtg.CardType.ARTIFACT)
	c.pt(0, 6)
	c.with_subtypes(["wall"])
	c.with_keywords([Mtg.Keyword.DEFENDER])
	c.oracle("Defender\nWhenever this creature blocks, put a -0/-1 counter on it.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
