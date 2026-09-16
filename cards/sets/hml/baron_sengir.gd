extends CardScript
## Baron Sengir — {5}{B}{B}{B} — Legendary Creature — Vampire Noble (rare, hml).
## Oracle: Flying
##         Whenever a creature dealt damage by Baron Sengir this turn dies, put a +2/+2 counter on Baron Sengir.
##         {T}: Regenerate another target Vampire.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Baron Sengir", "{5}{B}{B}{B}", Mtg.CardType.CREATURE)
	c.pt(5, 5)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["vampire","noble"])
	c.with_keywords([Mtg.Keyword.FLYING])
	c.oracle("Flying\nWhenever a creature dealt damage by Baron Sengir this turn dies, put a +2/+2 counter on Baron Sengir.\n{T}: Regenerate another target Vampire.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
