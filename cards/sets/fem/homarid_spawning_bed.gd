extends CardScript
## Homarid Spawning Bed — {U}{U} — Enchantment — (fem, uncommon)
## Oracle: {1}{U}{U}, Sacrifice a blue creature: Create X 1/1 blue Camarid creature tokens, where X is the sacrificed creature's mana value.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Homarid Spawning Bed", "{U}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("{1}{U}{U}, Sacrifice a blue creature: Create X 1/1 blue Camarid creature tokens, where X is the sacrificed creature's mana value.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
