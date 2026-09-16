extends CardScript
## Feroz's Ban — {6} — Artifact (rare, hml).
## Oracle: Creature spells cost {2} more to cast.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Feroz's Ban", "{6}", Mtg.CardType.ARTIFACT)
	c.pt(0, 0)
	c.oracle("Creature spells cost {2} more to cast.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
