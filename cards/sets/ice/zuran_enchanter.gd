extends CardScript
## Zuran Enchanter — {1}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Zuran Enchanter", "{1}{U}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","wizard"])
	card.oracle("{2}{B}, {T}: Target player discards a card. Activate only during your turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
