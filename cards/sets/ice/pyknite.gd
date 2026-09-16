extends CardScript
## Pyknite — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Pyknite", "{2}{G}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["ouphe"])
	card.oracle("When this creature enters, draw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
