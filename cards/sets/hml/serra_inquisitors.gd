extends CardScript
## Serra Inquisitors — {4}{W} — Creature — Human Cleric (uncommon, hml).
## Oracle: Whenever this creature blocks or becomes blocked by one or more black creatures, this creature gets +2/+0 until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Serra Inquisitors", "{4}{W}", Mtg.CardType.CREATURE)
	c.pt(3, 3)
	c.with_subtypes(["human","cleric"])
	c.oracle("Whenever this creature blocks or becomes blocked by one or more black creatures, this creature gets +2/+0 until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
