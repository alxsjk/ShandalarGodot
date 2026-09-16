extends CardScript
## Raiding Party — {2}{R} — Enchantment — (fem, uncommon)
## Oracle: This enchantment can't be the target of white spells or abilities from white sources.
##         Sacrifice an Orc: Each player may tap any number of untapped white creatures they control. For each creature tapped this way, that player chooses up to two Plains. Then destroy all Plains that weren't chosen this way by any player.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Raiding Party", "{2}{R}", Mtg.CardType.ENCHANTMENT)
	card.oracle("This enchantment can't be the target of white spells or abilities from white sources.\nSacrifice an Orc: Each player may tap any number of untapped white creatures they control. For each creature tapped this way, that player chooses up to two Plains. Then destroy all Plains that weren't chosen this way by any player.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
