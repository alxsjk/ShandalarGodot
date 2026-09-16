extends CardScript
## Walking Wall — {4} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Walking Wall", "{4}", Mtg.CardType.ARTIFACT | Mtg.CardType.CREATURE)
	card.pt(0, 6)
	card.with_subtypes(["wall"])
	card.with_keywords([Mtg.Keyword.DEFENDER])
	card.oracle("Defender\n{3}: This creature gets +3/-1 until end of turn and can attack this turn as though it didn't have defender. Activate only once each turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
