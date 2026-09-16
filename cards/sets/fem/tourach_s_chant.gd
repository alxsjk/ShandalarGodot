extends CardScript
## Tourach's Chant — {1}{B}{B} — Enchantment — (fem, uncommon)
## Oracle: At the beginning of your upkeep, sacrifice this enchantment unless you pay {B}.
##         Whenever a player puts a Forest onto the battlefield, this enchantment deals 3 damage to that player unless they put a -1/-1 counter on a creature they control.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Tourach's Chant", "{1}{B}{B}", Mtg.CardType.ENCHANTMENT)
	card.oracle("At the beginning of your upkeep, sacrifice this enchantment unless you pay {B}.\nWhenever a player puts a Forest onto the battlefield, this enchantment deals 3 damage to that player unless they put a -1/-1 counter on a creature they control.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
