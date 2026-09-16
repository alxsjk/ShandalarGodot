extends CardScript
## Goblin Kites — {1}{R} — Enchantment — (fem, uncommon)
## Oracle: {R}: Target creature you control with toughness 2 or less gains flying until end of turn. Flip a coin at the beginning of the next end step. If you lose the flip, sacrifice that creature.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Goblin Kites", "{1}{R}", Mtg.CardType.ENCHANTMENT)
	card.oracle("{R}: Target creature you control with toughness 2 or less gains flying until end of turn. Flip a coin at the beginning of the next end step. If you lose the flip, sacrifice that creature.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
