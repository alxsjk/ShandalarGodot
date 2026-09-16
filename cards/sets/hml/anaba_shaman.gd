extends CardScript
## Anaba Shaman — {3}{R} — Creature — Minotaur Shaman (common, hml).
## Oracle: {R}, {T}: This creature deals 1 damage to any target.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Anaba Shaman", "{3}{R}", Mtg.CardType.CREATURE)
	c.pt(2, 2)
	c.with_subtypes(["minotaur","shaman"])
	c.oracle("{R}, {T}: This creature deals 1 damage to any target.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
