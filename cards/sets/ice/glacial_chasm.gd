extends CardScript
## Glacial Chasm — no mana cost — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Glacial Chasm", "", Mtg.CardType.LAND)
	card.oracle("Cumulative upkeep—Pay 2 life. (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nWhen this land enters, sacrifice a land.\nCreatures you control can't attack.\nPrevent all damage that would be dealt to you.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
