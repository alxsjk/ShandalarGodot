extends CardScript
## Thrull Champion — {4}{B} — Creature — Thrull — 2/2 — (fem, rare)
## Oracle: Thrull creatures get +1/+1.
##         {T}: Gain control of target Thrull for as long as you control this creature.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Thrull Champion", "{4}{B}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["thrull"])
	card.oracle("Thrull creatures get +1/+1.\n{T}: Gain control of target Thrull for as long as you control this creature.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
