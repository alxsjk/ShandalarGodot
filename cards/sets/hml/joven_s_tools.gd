extends CardScript
## Joven's Tools — {6} — Artifact (uncommon, hml).
## Oracle: {4}, {T}: Target creature can't be blocked this turn except by Walls.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Joven's Tools", "{6}", Mtg.CardType.ARTIFACT)
	c.pt(0, 0)
	c.oracle("{4}, {T}: Target creature can't be blocked this turn except by Walls.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
