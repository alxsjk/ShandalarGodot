extends CardScript
## Wind Spirit — {4}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Wind Spirit", "{4}{U}", Mtg.CardType.CREATURE)
	card.pt(3, 2)
	card.with_subtypes(["elemental","spirit"])
	card.with_keywords([Mtg.Keyword.FLYING])
	card.oracle("Flying\nMenace (This creature can't be blocked except by two or more creatures.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
