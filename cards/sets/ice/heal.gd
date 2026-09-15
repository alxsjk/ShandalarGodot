extends CardScript
## Heal — {W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Heal", "{W}", Mtg.CardType.INSTANT)
	card.oracle("Prevent the next 1 damage that would be dealt to any target this turn.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
