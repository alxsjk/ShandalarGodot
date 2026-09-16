extends CardScript
## Labyrinth Minotaur — {3}{U} — Creature — Minotaur (common, hml).
## Oracle: Whenever this creature blocks a creature, that creature doesn't untap during its controller's next untap step.
## Trusted optional Pack 4 implementation; ZIPs never provide scripts.

func build() -> CardData:
	var c := CardData.new("Labyrinth Minotaur", "{3}{U}", Mtg.CardType.CREATURE)
	c.pt(1, 4)
	c.with_subtypes(["minotaur"])
	c.oracle("Whenever this creature blocks a creature, that creature doesn't untap during its controller's next untap step.")
	return load("res://cards/sets/hml/_rules.gd").apply(c)
