extends CardScript
## Krovikan Horror — {3}{B} — Creature — Horror Spirit (rare, all).
## Oracle: At the beginning of the end step, if this card is in your graveyard with a creature card directly above it, you may return this card to your hand.
##         {1}, Sacrifice a creature: This creature deals 1 damage to any target.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Krovikan Horror", "{3}{B}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["horror","spirit"])
	c.oracle("At the beginning of the end step, if this card is in your graveyard with a creature card directly above it, you may return this card to your hand.\n{1}, Sacrifice a creature: This creature deals 1 damage to any target.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
