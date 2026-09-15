extends CardScript
## Brassclaw Orcs — {2}{R} — Creature — Orc — 3/2 — (fem, common)
## Oracle: This creature can't block creatures with power 2 or greater.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Brassclaw Orcs", "{2}{R}", Mtg.CardType.CREATURE)
	card.pt(3, 2)
	card.with_subtypes(["orc"])
	card.oracle("This creature can't block creatures with power 2 or greater.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
