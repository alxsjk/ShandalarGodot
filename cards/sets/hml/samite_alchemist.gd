extends CardScript
## Samite Alchemist — {3}{W} — Creature — Human Cleric (common, hml).
## Oracle: {W}{W}, {T}: Prevent the next 4 damage that would be dealt this turn to target creature you control. Tap that creature. It doesn't untap during your next untap step.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Samite Alchemist", "{3}{W}", Mtg.CardType.CREATURE)
	c.pt(0, 2)
	c.with_subtypes(["human","cleric"])
	c.oracle("{W}{W}, {T}: Prevent the next 4 damage that would be dealt this turn to target creature you control. Tap that creature. It doesn't untap during your next untap step.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
