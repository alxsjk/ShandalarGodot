extends CardScript
## Dwarven Soldier — {1}{R} — Creature — Dwarf Soldier — 2/1 — (fem, common)
## Oracle: Whenever this creature blocks or becomes blocked by one or more Orcs, this creature gets +0/+2 until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Dwarven Soldier", "{1}{R}", Mtg.CardType.CREATURE)
	card.pt(2, 1)
	card.with_subtypes(["dwarf", "soldier"])
	card.oracle("Whenever this creature blocks or becomes blocked by one or more Orcs, this creature gets +0/+2 until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
