extends CardScript
## Mystic Remora — {U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Mystic Remora", "{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Cumulative upkeep {1} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nWhenever an opponent casts a noncreature spell, you may draw a card unless that player pays {4}.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
