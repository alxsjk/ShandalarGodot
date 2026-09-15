extends CardScript
## Zuran Spellcaster — {2}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Zuran Spellcaster", "{2}{U}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","wizard"])
	card.oracle("{T}: This creature deals 1 damage to any target.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
