extends CardScript
## Krovikan Vampire — {3}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Krovikan Vampire", "{3}{B}{B}", Mtg.CardType.CREATURE)
	card.pt(3, 3)
	card.with_subtypes(["vampire"])
	card.oracle("At the beginning of each end step, if a creature dealt damage by this creature this turn died, put that card onto the battlefield under your control. Sacrifice it when you lose control of this creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
