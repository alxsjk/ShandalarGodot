extends CardScript
## Word of Undoing — {U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Word of Undoing", "{U}", Mtg.CardType.INSTANT)
	card.oracle("Return target creature and all white Auras you own attached to it to their owners' hands.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
