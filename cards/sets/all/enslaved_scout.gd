extends CardScript
## Enslaved Scout — {2}{R} — Creature — Goblin Scout (common, all).
## Oracle: {2}: This creature gains mountainwalk until end of turn. (It can't be blocked as long as defending player controls a Mountain.)
## Trusted optional Pack 5 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Enslaved Scout", "{2}{R}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["goblin","scout"])
	c.oracle("{2}: This creature gains mountainwalk until end of turn. (It can't be blocked as long as defending player controls a Mountain.)")
	return load("res://cards/sets/all/_rules.gd").apply(c)
