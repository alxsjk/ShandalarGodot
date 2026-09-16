extends CardScript
## Lord of Tresserhorn — {1}{U}{B}{R} — Legendary Creature — Zombie (rare, all).
## Oracle: When Lord of Tresserhorn enters, you lose 2 life, you sacrifice two creatures, and target opponent draws two cards.
##         {B}: Regenerate Lord of Tresserhorn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Lord of Tresserhorn", "{1}{U}{B}{R}", Mtg.CardType.CREATURE)
	c.pt(10, 4)
	c.with_subtypes(["zombie"])
	c.supertypes |= Mtg.Supertype.LEGENDARY
	c.oracle("When Lord of Tresserhorn enters, you lose 2 life, you sacrifice two creatures, and target opponent draws two cards.\n{B}: Regenerate Lord of Tresserhorn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
