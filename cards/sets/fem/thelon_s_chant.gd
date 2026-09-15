extends CardScript
## Thelon's Chant — {1}{G}{G} — Enchantment — (fem, uncommon)
## Oracle: At the beginning of your upkeep, sacrifice this enchantment unless you pay {G}.
##         Whenever a player puts a Swamp onto the battlefield, this enchantment deals 3 damage to that player unless the player puts a -1/-1 counter on a creature they control.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Thelon's Chant", "{1}{G}{G}", Mtg.CardType.ENCHANTMENT)
	card.oracle("At the beginning of your upkeep, sacrifice this enchantment unless you pay {G}.\nWhenever a player puts a Swamp onto the battlefield, this enchantment deals 3 damage to that player unless the player puts a -1/-1 counter on a creature they control.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
