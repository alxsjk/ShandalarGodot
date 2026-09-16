extends CardScript
## Staff of the Ages — {3} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Staff of the Ages", "{3}", Mtg.CardType.ARTIFACT)
	card.oracle("Creatures with landwalk abilities can be blocked as though they didn't have those abilities.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
