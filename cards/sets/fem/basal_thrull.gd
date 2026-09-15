extends CardScript
## Basal Thrull — {B}{B} — Creature — Thrull — 1/2 — (fem, common)
## Oracle: {T}, Sacrifice this creature: Add {B}{B}.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Basal Thrull", "{B}{B}", Mtg.CardType.CREATURE)
	card.pt(1, 2)
	card.with_subtypes(["thrull"])
	card.oracle("{T}, Sacrifice this creature: Add {B}{B}.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
