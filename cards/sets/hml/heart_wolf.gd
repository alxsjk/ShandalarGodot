extends CardScript
## Heart Wolf — {3}{R} — Creature — Wolf (rare, hml).
## Oracle: First strike
##         {T}: Target Dwarf creature gets +2/+0 and gains first strike until end of turn. When that creature leaves the battlefield this turn, sacrifice this creature. Activate only during combat.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Heart Wolf", "{3}{R}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["wolf"])
	c.with_keywords([Mtg.Keyword.FIRST_STRIKE])
	c.oracle("First strike\n{T}: Target Dwarf creature gets +2/+0 and gains first strike until end of turn. When that creature leaves the battlefield this turn, sacrifice this creature. Activate only during combat.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
