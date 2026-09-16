extends CardScript
## Draconian Cylix — {3} — Artifact — (fem, rare)
## Oracle: {2}, {T}, Discard a card at random: Regenerate target creature.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Draconian Cylix", "{3}", Mtg.CardType.ARTIFACT)
	card.oracle("{2}, {T}, Discard a card at random: Regenerate target creature.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
