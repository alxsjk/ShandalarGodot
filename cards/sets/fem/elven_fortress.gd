extends CardScript
## Elven Fortress — {G} — Enchantment — (fem, common)
## Oracle: {1}{G}: Target blocking creature gets +0/+1 until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Elven Fortress", "{G}", Mtg.CardType.ENCHANTMENT)
	card.oracle("{1}{G}: Target blocking creature gets +0/+1 until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
