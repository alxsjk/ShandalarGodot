extends CardScript
## Insidious Bookworms — {B} — Creature — Worm (common, all).
## Oracle: When this creature dies, you may pay {1}{B}. If you do, target player discards a card at random.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Insidious Bookworms", "{B}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["worm"])
	c.oracle("When this creature dies, you may pay {1}{B}. If you do, target player discards a card at random.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
