extends CardScript
## Goblin War Drums — {2}{R} — Enchantment — (fem, common)
## Oracle: Creatures you control have menace. (They can't be blocked except by two or more creatures.)
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Goblin War Drums", "{2}{R}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Creatures you control have menace. (They can't be blocked except by two or more creatures.)")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
