extends CardScript
## Trailblazer — {2}{G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Trailblazer", "{2}{G}{G}", Mtg.CardType.INSTANT)
	card.oracle("Target creature can't be blocked this turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
