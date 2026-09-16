extends CardScript
## Force Void — {2}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Force Void", "{2}{U}", Mtg.CardType.INSTANT)
	card.oracle("Counter target spell unless its controller pays {1}.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
