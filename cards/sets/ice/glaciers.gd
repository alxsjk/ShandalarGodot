extends CardScript
## Glaciers — {2}{W}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Glaciers", "{2}{W}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("At the beginning of your upkeep, sacrifice this enchantment unless you pay {W}{U}.\nAll Mountains are Plains.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
