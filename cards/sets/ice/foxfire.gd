extends CardScript
## Foxfire — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Foxfire", "{2}{G}", Mtg.CardType.INSTANT)
	card.oracle("Untap target attacking creature. Prevent all combat damage that would be dealt to and dealt by that creature this turn.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
