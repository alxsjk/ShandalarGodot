extends CardScript
## Ring of Renewal — {5} — Artifact — (fem, rare)
## Oracle: {5}, {T}: Discard a card at random, then draw two cards.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Ring of Renewal", "{5}", Mtg.CardType.ARTIFACT)
	card.oracle("{5}, {T}: Discard a card at random, then draw two cards.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
