extends CardScript
## Dwarven Armory — {2}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Dwarven Armory", "{2}{R}{R}", Mtg.CardType.ENCHANTMENT)
	card.oracle("{2}, Sacrifice a land: Put a +2/+2 counter on target creature. Activate only during any upkeep step.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
