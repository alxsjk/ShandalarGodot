extends CardScript
## Vertigo — {R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Vertigo", "{R}", Mtg.CardType.INSTANT)
	card.oracle("Vertigo deals 2 damage to target creature with flying. That creature loses flying until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
