extends CardScript
## Gorilla Chieftain — {2}{G}{G} — Creature — Ape (common, all).
## Oracle: {1}{G}: Regenerate this creature.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Gorilla Chieftain", "{2}{G}{G}", Mtg.CardType.CREATURE)
	c.pt(3, 3)
	c.with_subtypes(["ape"])
	c.oracle("{1}{G}: Regenerate this creature.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
