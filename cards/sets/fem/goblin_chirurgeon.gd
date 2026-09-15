extends CardScript
## Goblin Chirurgeon — {R} — Creature — Goblin Shaman — 0/2 — (fem, common)
## Oracle: Sacrifice a Goblin: Regenerate target creature.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Goblin Chirurgeon", "{R}", Mtg.CardType.CREATURE)
	card.pt(0, 2)
	card.with_subtypes(["goblin", "shaman"])
	card.oracle("Sacrifice a Goblin: Regenerate target creature.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
