extends CardScript
## Sibilant Spirit — {5}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Sibilant Spirit", "{5}{U}", Mtg.CardType.CREATURE)
	card.pt(5, 6)
	card.with_subtypes(["spirit"])
	card.with_keywords([Mtg.Keyword.FLYING])
	card.oracle("Flying\nWhenever this creature attacks, defending player may draw a card.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
