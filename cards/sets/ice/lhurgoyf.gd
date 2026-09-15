extends CardScript
## Lhurgoyf — {2}{G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Lhurgoyf", "{2}{G}{G}", Mtg.CardType.CREATURE)
	card.pt(0, 1)
	card.with_subtypes(["lhurgoyf"])
	card.oracle("Lhurgoyf's power is equal to the number of creature cards in all graveyards and its toughness is equal to that number plus 1.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
