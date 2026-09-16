extends CardScript
## Glacial Crevasses — {2}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Glacial Crevasses", "{2}{R}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Sacrifice a snow Mountain: Prevent all combat damage that would be dealt this turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
