extends CardScript
## Pyroclasm — {1}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Pyroclasm", "{1}{R}", Mtg.CardType.SORCERY)
	card.oracle("Pyroclasm deals 2 damage to each creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
