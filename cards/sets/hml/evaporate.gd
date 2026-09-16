extends CardScript
## Evaporate — {2}{R} — Sorcery (uncommon, hml).
## Oracle: Evaporate deals 1 damage to each white and/or blue creature.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Evaporate", "{2}{R}", Mtg.CardType.SORCERY)
	c.pt(0, 0)
	c.oracle("Evaporate deals 1 damage to each white and/or blue creature.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
