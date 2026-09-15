extends CardScript
## Glacial Wall — {2}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Glacial Wall", "{2}{U}", Mtg.CardType.CREATURE)
	card.pt(0, 7)
	card.with_subtypes(["wall"])
	card.with_keywords([Mtg.Keyword.DEFENDER])
	card.oracle("Defender (This creature can't attack.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
