extends CardScript
## Lim-Dûl's Cohort — {1}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Lim-Dûl's Cohort", "{1}{B}{B}", Mtg.CardType.CREATURE)
	card.pt(2, 3)
	card.with_subtypes(["zombie"])
	card.oracle("Whenever this creature blocks or becomes blocked by a creature, that creature can't be regenerated this turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
