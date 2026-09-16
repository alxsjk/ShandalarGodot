extends CardScript
## Dwarven Pony — {R} — Creature — Horse (rare, hml).
## Oracle: {1}{R}, {T}: Target Dwarf creature gains mountainwalk until end of turn. (It can't be blocked as long as defending player controls a Mountain.)
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Dwarven Pony", "{R}", Mtg.CardType.CREATURE)
	c.pt(1, 1)
	c.with_subtypes(["horse"])
	c.oracle("{1}{R}, {T}: Target Dwarf creature gains mountainwalk until end of turn. (It can't be blocked as long as defending player controls a Mountain.)")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
