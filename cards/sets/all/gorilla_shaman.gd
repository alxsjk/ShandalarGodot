extends CardScript
## Gorilla Shaman — {R} — Creature — Ape Shaman (common, all).
## Oracle: {X}{X}{1}: Destroy target noncreature artifact with mana value X.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Gorilla Shaman", "{R}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["ape","shaman"])
	c.oracle("{X}{X}{1}: Destroy target noncreature artifact with mana value X.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
