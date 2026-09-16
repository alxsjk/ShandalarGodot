extends CardScript
## Veldrane of Sengir — {5}{B}{B} — Legendary Creature — Human Rogue (rare, hml).
## Oracle: {1}{B}{B}: Veldrane gets -3/-0 and gains forestwalk until end of turn. (It can't be blocked as long as defending player controls a Forest.)
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Veldrane of Sengir", "{5}{B}{B}", Mtg.CardType.CREATURE)
	c.pt(5, 5)
	c.with_supertypes(Mtg.Supertype.LEGENDARY)
	c.with_subtypes(["human","rogue"])
	c.oracle("{1}{B}{B}: Veldrane gets -3/-0 and gains forestwalk until end of turn. (It can't be blocked as long as defending player controls a Forest.)")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
