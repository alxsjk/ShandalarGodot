extends CardScript
## Yavimaya Gnats — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Yavimaya Gnats", "{2}{G}", Mtg.CardType.CREATURE)
	card.pt(0, 1)
	card.with_subtypes(["insect"])
	card.with_keywords([Mtg.Keyword.FLYING])
	card.oracle("Flying\n{G}: Regenerate this creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
