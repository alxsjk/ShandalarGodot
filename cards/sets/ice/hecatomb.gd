extends CardScript
## Hecatomb — {1}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Hecatomb", "{1}{B}{B}", Mtg.CardType.ENCHANTMENT)
	card.oracle("When this enchantment enters, sacrifice this enchantment unless you sacrifice four creatures.\nTap an untapped Swamp you control: This enchantment deals 1 damage to any target.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
