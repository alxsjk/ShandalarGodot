extends CardScript
## Thelon's Curse — {G}{G} — Enchantment — (fem, rare)
## Oracle: Blue creatures don't untap during their controllers' untap steps.
##         At the beginning of each player's upkeep, that player may choose any number of tapped blue creatures they control and pay {U} for each creature chosen this way. If the player does, untap those creatures.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Thelon's Curse", "{G}{G}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Blue creatures don't untap during their controllers' untap steps.\nAt the beginning of each player's upkeep, that player may choose any number of tapped blue creatures they control and pay {U} for each creature chosen this way. If the player does, untap those creatures.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
