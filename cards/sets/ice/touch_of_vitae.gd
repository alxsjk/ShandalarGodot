extends CardScript
## Touch of Vitae — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Touch of Vitae", "{2}{G}", Mtg.CardType.INSTANT)
	card.oracle("Until end of turn, target creature gains haste and \"{0}: Untap this creature. Activate only once.\"\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
