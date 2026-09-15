extends CardScript
## Pentagram of the Ages — {4} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Pentagram of the Ages", "{4}", Mtg.CardType.ARTIFACT)
	card.oracle("{4}, {T}: The next time a source of your choice would deal damage to you this turn, prevent that damage.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
