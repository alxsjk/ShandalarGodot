extends CardScript
## Delif's Cone — {0} — Artifact — (fem, common)
## Oracle: {T}, Sacrifice this artifact: This turn, when target creature you control attacks and isn't blocked, you may gain life equal to its power. If you do, it assigns no combat damage this turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Delif's Cone", "{0}", Mtg.CardType.ARTIFACT)
	card.oracle("{T}, Sacrifice this artifact: This turn, when target creature you control attacks and isn't blocked, you may gain life equal to its power. If you do, it assigns no combat damage this turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
