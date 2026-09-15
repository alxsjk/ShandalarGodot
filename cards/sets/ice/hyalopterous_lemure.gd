extends CardScript
## Hyalopterous Lemure — {4}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Hyalopterous Lemure", "{4}{B}", Mtg.CardType.CREATURE)
	card.pt(4, 3)
	card.with_subtypes(["spirit"])
	card.oracle("{0}: This creature gets -1/-0 and gains flying until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
