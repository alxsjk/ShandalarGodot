extends CardScript
## Stormbind — {1}{R}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Stormbind", "{1}{R}{G}", Mtg.CardType.ENCHANTMENT)
	card.oracle("{2}, Discard a card at random: This enchantment deals 2 damage to any target.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
