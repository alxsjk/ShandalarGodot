extends CardScript
## Spoils of Evil — {2}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Spoils of Evil", "{2}{B}", Mtg.CardType.INSTANT)
	card.oracle("For each artifact or creature card in target opponent's graveyard, add {C} and you gain 1 life.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
