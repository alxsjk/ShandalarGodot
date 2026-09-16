extends CardScript
## Initiates of the Ebon Hand — {B} — Creature — Cleric — 1/1 — (fem, common)
## Oracle: {1}: Add {B}. If this ability has been activated four or more times this turn, sacrifice this creature at the beginning of the next end step.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Initiates of the Ebon Hand", "{B}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["cleric"])
	card.oracle("{1}: Add {B}. If this ability has been activated four or more times this turn, sacrifice this creature at the beginning of the next end step.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
