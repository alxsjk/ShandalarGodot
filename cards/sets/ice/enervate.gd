extends CardScript
## Enervate — {1}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Enervate", "{1}{U}", Mtg.CardType.INSTANT)
	card.oracle("Tap target artifact, creature, or land.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
