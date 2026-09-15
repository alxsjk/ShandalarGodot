extends CardScript
## Anarchy — {2}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Anarchy", "{2}{R}{R}", Mtg.CardType.SORCERY)
	card.oracle("Destroy all white permanents.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
