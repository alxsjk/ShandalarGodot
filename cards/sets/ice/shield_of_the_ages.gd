extends CardScript
## Shield of the Ages — {2} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Shield of the Ages", "{2}", Mtg.CardType.ARTIFACT)
	card.oracle("{2}: Prevent the next 1 damage that would be dealt to you this turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
