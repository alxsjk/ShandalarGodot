extends CardScript
## Anaba Ancestor — {1}{R} — Creature — Minotaur Spirit (rare, hml).
## Oracle: {T}: Another target Minotaur creature gets +1/+1 until end of turn.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Anaba Ancestor", "{1}{R}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["minotaur","spirit"])
	c.oracle("{T}: Another target Minotaur creature gets +1/+1 until end of turn.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
