extends CardScript
## Dwarven Lieutenant — {R}{R} — Creature — Dwarf Soldier — 1/2 — (fem, uncommon)
## Oracle: {1}{R}: Target Dwarf creature gets +1/+0 until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Dwarven Lieutenant", "{R}{R}", Mtg.CardType.CREATURE)
	card.pt(1, 2)
	card.with_subtypes(["dwarf", "soldier"])
	card.oracle("{1}{R}: Target Dwarf creature gets +1/+0 until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
