extends CardScript
## Gaze of Pain — {1}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Gaze of Pain", "{1}{B}", Mtg.CardType.SORCERY)
	card.oracle("Until end of turn, whenever a creature you control attacks and isn't blocked, you may choose to have it deal damage equal to its power to a target creature. If you do, it assigns no combat damage this turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
