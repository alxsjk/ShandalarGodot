extends CardScript
## Mistfolk — {U}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Mistfolk", "{U}{U}", Mtg.CardType.CREATURE)
	card.pt(1, 2)
	card.with_subtypes(["illusion"])
	card.oracle("{U}: Counter target spell that targets this creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
