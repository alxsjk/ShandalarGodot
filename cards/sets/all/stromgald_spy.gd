extends CardScript
## Stromgald Spy — {3}{B} — Creature — Human Rogue (uncommon, all).
## Oracle: Whenever this creature attacks and isn't blocked, you may have defending player play with their hand revealed for as long as this creature remains on the battlefield. If you do, this creature assigns no combat damage this turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Stromgald Spy", "{3}{B}", Mtg.CardType.CREATURE)
	c.pt(2, 4)
	c.with_subtypes(["human","rogue"])
	c.oracle("Whenever this creature attacks and isn't blocked, you may have defending player play with their hand revealed for as long as this creature remains on the battlefield. If you do, this creature assigns no combat damage this turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
