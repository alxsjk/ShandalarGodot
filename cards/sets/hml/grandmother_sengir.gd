extends CardScript
## Grandmother Sengir — {4}{B} — Legendary Creature — Human Wizard (rare, hml).
## Oracle: {1}{B}, {T}: Target creature gets -1/-1 until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Grandmother Sengir", "{4}{B}", Mtg.CardType.CREATURE)
	c.pt(3, 3)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["human","wizard"])
	c.oracle("{1}{B}, {T}: Target creature gets -1/-1 until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
