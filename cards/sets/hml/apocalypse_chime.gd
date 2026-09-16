extends CardScript
## Apocalypse Chime — {2} — Artifact (rare, hml).
## Oracle: {2}, {T}, Sacrifice this artifact: Destroy all nontoken permanents with a name originally printed in the Homelands expansion. They can't be regenerated.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Apocalypse Chime", "{2}", Mtg.CardType.ARTIFACT)
	c.pt(0, 0)
	c.oracle("{2}, {T}, Sacrifice this artifact: Destroy all nontoken permanents with a name originally printed in the Homelands expansion. They can't be regenerated.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
