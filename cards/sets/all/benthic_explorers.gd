extends CardScript
## Benthic Explorers — {3}{U} — Creature — Merfolk Scout (common, all).
## Oracle: {T}, Untap a tapped land an opponent controls: Add one mana of any type that land could produce.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Benthic Explorers", "{3}{U}", Mtg.CardType.CREATURE)
	c.pt(2, 4)
	c.with_subtypes(["merfolk","scout"])
	c.oracle("{T}, Untap a tapped land an opponent controls: Add one mana of any type that land could produce.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
