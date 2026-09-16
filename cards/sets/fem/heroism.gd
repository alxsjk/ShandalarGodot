extends CardScript
## Heroism — {2}{W} — Enchantment — (fem, uncommon)
## Oracle: Sacrifice a white creature: For each attacking red creature, prevent all combat damage that would be dealt by that creature this turn unless its controller pays {2}{R}.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Heroism", "{2}{W}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Sacrifice a white creature: For each attacking red creature, prevent all combat damage that would be dealt by that creature this turn unless its controller pays {2}{R}.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
