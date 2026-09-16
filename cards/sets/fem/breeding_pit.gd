extends CardScript
## Breeding Pit — {3}{B} — Enchantment — (fem, uncommon)
## Oracle: At the beginning of your upkeep, sacrifice this enchantment unless you pay {B}{B}.
##         At the beginning of your end step, create a 0/1 black Thrull creature token.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Breeding Pit", "{3}{B}", Mtg.CardType.ENCHANTMENT)
	card.oracle("At the beginning of your upkeep, sacrifice this enchantment unless you pay {B}{B}.\nAt the beginning of your end step, create a 0/1 black Thrull creature token.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
