extends CardScript
## Elkin Bottle — {3} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Elkin Bottle", "{3}", Mtg.CardType.ARTIFACT)
	card.oracle("{3}, {T}: Exile the top card of your library. Until the beginning of your next upkeep, you may play that card.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
