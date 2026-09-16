extends CardScript
## Clairvoyance — {U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Clairvoyance", "{U}", Mtg.CardType.INSTANT)
	card.oracle("Look at target player's hand.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
