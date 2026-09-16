extends CardScript
## Thrull Wizard — {2}{B} — Creature — Thrull Wizard — 1/1 — (fem, uncommon)
## Oracle: {1}{B}: Counter target black spell unless that spell's controller pays {B} or {3}.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Thrull Wizard", "{2}{B}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["thrull", "wizard"])
	card.oracle("{1}{B}: Counter target black spell unless that spell's controller pays {B} or {3}.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
