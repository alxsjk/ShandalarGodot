extends CardScript
## Oath of Lim-Dûl — {3}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Oath of Lim-Dûl", "{3}{B}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Whenever you lose life, for each 1 life you lost, sacrifice a permanent other than this enchantment unless you discard a card. (Damage dealt to you causes you to lose life.)\n{B}{B}: Draw a card.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
