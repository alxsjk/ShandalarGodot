extends CardScript
## Chaos Moon — {3}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Chaos Moon", "{3}{R}", Mtg.CardType.ENCHANTMENT)
	card.oracle("At the beginning of each upkeep, count the number of permanents. If the number is odd, until end of turn, red creatures get +1/+1 and whenever a player taps a Mountain for mana, that player adds an additional {R}. If the number is even, until end of turn, red creatures get -1/-1 and if a player taps a Mountain for mana, that Mountain produces colorless mana instead of any other type.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
