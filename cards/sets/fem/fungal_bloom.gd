extends CardScript
## Fungal Bloom — {G}{G} — Enchantment — (fem, rare)
## Oracle: {G}{G}: Put a spore counter on target Fungus.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Fungal Bloom", "{G}{G}", Mtg.CardType.ENCHANTMENT)
	card.oracle("{G}{G}: Put a spore counter on target Fungus.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
