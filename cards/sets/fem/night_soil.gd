extends CardScript
## Night Soil — {G}{G} — Enchantment — (fem, common)
## Oracle: {1}, Exile two creature cards from a single graveyard: Create a 1/1 green Saproling creature token.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Night Soil", "{G}{G}", Mtg.CardType.ENCHANTMENT)
	card.oracle("{1}, Exile two creature cards from a single graveyard: Create a 1/1 green Saproling creature token.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
