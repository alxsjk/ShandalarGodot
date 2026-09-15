extends CardScript
## Warning — {W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Warning", "{W}", Mtg.CardType.INSTANT)
	card.oracle("Prevent all combat damage that would be dealt by target attacking creature this turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
