extends CardScript
## Dwarven Armorer — {R} — Creature — Dwarf — 0/2 — (fem, rare)
## Oracle: {R}, {T}, Discard a card: Put a +0/+1 counter or a +1/+0 counter on target creature.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Dwarven Armorer", "{R}", Mtg.CardType.CREATURE)
	card.pt(0, 2)
	card.with_subtypes(["dwarf"])
	card.oracle("{R}, {T}, Discard a card: Put a +0/+1 counter or a +1/+0 counter on target creature.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
