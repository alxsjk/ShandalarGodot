extends CardScript
## Astrolabe — {3} — Artifact (common, all).
## Oracle: {1}, {T}, Sacrifice this artifact: Add two mana of any one color. Draw a card at the beginning of the next turn's upkeep.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Astrolabe", "{3}", Mtg.CardType.ARTIFACT)
	c.oracle("{1}, {T}, Sacrifice this artifact: Add two mana of any one color. Draw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
