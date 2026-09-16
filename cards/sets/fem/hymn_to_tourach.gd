extends CardScript
## Hymn to Tourach — {B}{B} — Sorcery — (fem, common)
## Oracle: Target player discards two cards at random.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Hymn to Tourach", "{B}{B}", Mtg.CardType.SORCERY)
	card.oracle("Target player discards two cards at random.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
