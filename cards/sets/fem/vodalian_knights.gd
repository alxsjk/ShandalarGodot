extends CardScript
## Vodalian Knights — {1}{U}{U} — Creature — Merfolk Knight — 2/2 — (fem, rare)
## Oracle: First strike
##         This creature can't attack unless defending player controls an Island.
##         When you control no Islands, sacrifice this creature.
##         {U}: This creature gains flying until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Vodalian Knights", "{1}{U}{U}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["merfolk", "knight"])
	card.with_keywords([Mtg.Keyword.FIRST_STRIKE])
	card.oracle("First strike\nThis creature can't attack unless defending player controls an Island.\nWhen you control no Islands, sacrifice this creature.\n{U}: This creature gains flying until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
