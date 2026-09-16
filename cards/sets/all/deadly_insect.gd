extends CardScript
## Deadly Insect — {4}{G} — Creature — Insect (common, all).
## Oracle: Shroud (This creature can't be the target of spells or abilities.)
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Deadly Insect", "{4}{G}", Mtg.CardType.CREATURE)
	c.pt(6, 1)
	c.with_subtypes(["insect"])
	c.oracle("Shroud (This creature can't be the target of spells or abilities.)")
	return load("res://cards/sets/all/_rules.gd").apply(c)
