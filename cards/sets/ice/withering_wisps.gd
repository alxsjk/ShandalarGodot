extends CardScript
## Withering Wisps — {1}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Withering Wisps", "{1}{B}{B}", Mtg.CardType.ENCHANTMENT)
	card.oracle("At the beginning of the end step, if no creatures are on the battlefield, sacrifice this enchantment.\n{B}: This enchantment deals 1 damage to each creature and each player. Activate no more times each turn than the number of snow Swamps you control.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
