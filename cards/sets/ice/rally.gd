extends CardScript
## Rally — {W}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Rally", "{W}{W}", Mtg.CardType.INSTANT)
	card.oracle("Blocking creatures get +1/+1 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
