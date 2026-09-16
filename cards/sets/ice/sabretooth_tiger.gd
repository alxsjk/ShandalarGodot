extends CardScript
## Sabretooth Tiger — {2}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Sabretooth Tiger", "{2}{R}", Mtg.CardType.CREATURE)
	card.pt(2, 1)
	card.with_subtypes(["cat"])
	card.with_keywords([Mtg.Keyword.FIRST_STRIKE])
	card.oracle("First strike")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
