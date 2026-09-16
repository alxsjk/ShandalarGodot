extends CardScript
## Lim-Dûl's Hex — {1}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Lim-Dûl's Hex", "{1}{B}", Mtg.CardType.ENCHANTMENT)
	card.oracle("At the beginning of your upkeep, for each player, this enchantment deals 1 damage to that player unless they pay {B} or {3}.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
