extends CardScript
## Implements of Sacrifice — {2} — Artifact — (fem, rare)
## Oracle: {1}, {T}, Sacrifice this artifact: Add two mana of any one color.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Implements of Sacrifice", "{2}", Mtg.CardType.ARTIFACT)
	card.oracle("{1}, {T}, Sacrifice this artifact: Add two mana of any one color.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
