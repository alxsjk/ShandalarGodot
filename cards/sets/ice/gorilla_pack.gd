extends CardScript
## Gorilla Pack — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Gorilla Pack", "{2}{G}", Mtg.CardType.CREATURE)
	card.pt(3, 3)
	card.with_subtypes(["ape"])
	card.oracle("This creature can't attack unless defending player controls a Forest.\nWhen you control no Forests, sacrifice this creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
