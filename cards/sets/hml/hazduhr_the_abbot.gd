extends CardScript
## Hazduhr the Abbot — {3}{W}{W} — Legendary Creature — Human Cleric (rare, hml).
## Oracle: {X}, {T}: The next X damage that would be dealt this turn to target white creature you control is dealt to Hazduhr instead.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Hazduhr the Abbot", "{3}{W}{W}", Mtg.CardType.CREATURE)
	c.pt(2, 5)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["human","cleric"])
	c.oracle("{X}, {T}: The next X damage that would be dealt this turn to target white creature you control is dealt to Hazduhr instead.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
