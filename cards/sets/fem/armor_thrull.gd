extends CardScript
## Armor Thrull — {2}{B} — Creature — Thrull — 1/3 — (fem, common)
## Oracle: {T}, Sacrifice this creature: Put a +1/+2 counter on target creature.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Armor Thrull", "{2}{B}", Mtg.CardType.CREATURE)
	card.pt(1, 3)
	card.with_subtypes(["thrull"])
	card.oracle("{T}, Sacrifice this creature: Put a +1/+2 counter on target creature.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
