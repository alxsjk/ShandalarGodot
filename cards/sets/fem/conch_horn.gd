extends CardScript
## Conch Horn — {2} — Artifact — (fem, rare)
## Oracle: {1}, {T}, Sacrifice this artifact: Draw two cards, then put a card from your hand on top of your library.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Conch Horn", "{2}", Mtg.CardType.ARTIFACT)
	card.oracle("{1}, {T}, Sacrifice this artifact: Draw two cards, then put a card from your hand on top of your library.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
