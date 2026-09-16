extends CardScript
## Balduvian Horde — {2}{R}{R} — Creature — Human Barbarian (rare, all).
## Oracle: When this creature enters, sacrifice it unless you discard a card at random.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Balduvian Horde", "{2}{R}{R}", Mtg.CardType.CREATURE)
	c.pt(5, 5)
	c.with_subtypes(["human","barbarian"])
	c.oracle("When this creature enters, sacrifice it unless you discard a card at random.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
