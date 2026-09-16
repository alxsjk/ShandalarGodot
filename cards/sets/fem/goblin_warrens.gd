extends CardScript
## Goblin Warrens — {2}{R} — Enchantment — (fem, rare)
## Oracle: {2}{R}, Sacrifice two Goblins: Create three 1/1 red Goblin creature tokens.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Goblin Warrens", "{2}{R}", Mtg.CardType.ENCHANTMENT)
	card.oracle("{2}{R}, Sacrifice two Goblins: Create three 1/1 red Goblin creature tokens.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
