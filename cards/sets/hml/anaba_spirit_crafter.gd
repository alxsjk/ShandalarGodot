extends CardScript
## Anaba Spirit Crafter — {2}{R}{R} — Creature — Minotaur Shaman (rare, hml).
## Oracle: Minotaur creatures get +1/+0.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Anaba Spirit Crafter", "{2}{R}{R}", Mtg.CardType.CREATURE)
	c.pt(1, 3)
	c.with_subtypes(["minotaur","shaman"])
	c.oracle("Minotaur creatures get +1/+0.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
