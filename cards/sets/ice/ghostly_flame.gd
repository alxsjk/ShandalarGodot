extends CardScript
## Ghostly Flame — {B}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Ghostly Flame", "{B}{R}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Black and/or red permanents and spells are colorless sources of damage.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
