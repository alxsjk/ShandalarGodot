extends CardScript
## Phantasmal Fiend — {3}{B} — Creature — Illusion (common, all).
## Oracle: {B}: This creature gets +1/-1 until end of turn.
##         {1}{U}: Switch this creature's power and toughness until end of turn.
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Phantasmal Fiend", "{3}{B}", Mtg.CardType.CREATURE)
	c.pt(1, 5)
	c.with_subtypes(["illusion"])
	c.oracle("{B}: This creature gets +1/-1 until end of turn.\n{1}{U}: Switch this creature's power and toughness until end of turn.")
	return load("res://cards/sets/all/_rules.gd").apply(c)
