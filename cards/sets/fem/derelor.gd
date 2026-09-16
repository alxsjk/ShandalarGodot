extends CardScript
## Derelor — {3}{B} — Creature — Thrull — 4/4 — (fem, rare)
## Oracle: Black spells you cast cost {B} more to cast.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Derelor", "{3}{B}", Mtg.CardType.CREATURE)
	card.pt(4, 4)
	card.with_subtypes(["thrull"])
	card.oracle("Black spells you cast cost {B} more to cast.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
