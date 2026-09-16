extends CardScript
## Keeper of Tresserhorn — {5}{B} — Creature — Avatar (rare, all).
## Oracle: Whenever this creature attacks and isn't blocked, it assigns no combat damage this turn and defending player loses 2 life.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Keeper of Tresserhorn", "{5}{B}", Mtg.CardType.CREATURE)
	c.pt(6, 6)
	c.with_subtypes(["avatar"])
	c.oracle("Whenever this creature attacks and isn't blocked, it assigns no combat damage this turn and defending player loses 2 life.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
