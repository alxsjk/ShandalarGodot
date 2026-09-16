extends CardScript
## Vodalian Soldiers — {1}{U} — Creature — Merfolk Soldier — 1/2 — (fem, common)
## Oracle: (no rules text — vanilla creature)
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Vodalian Soldiers", "{1}{U}", Mtg.CardType.CREATURE)
	card.pt(1, 2)
	card.with_subtypes(["merfolk", "soldier"])
	card.oracle("")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
