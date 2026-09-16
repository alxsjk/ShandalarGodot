extends CardScript
## Aeolipile — {2} — Artifact — (fem, rare)
## Oracle: {1}, {T}, Sacrifice this artifact: It deals 2 damage to any target.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Aeolipile", "{2}", Mtg.CardType.ARTIFACT)
	card.oracle("{1}, {T}, Sacrifice this artifact: It deals 2 damage to any target.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
