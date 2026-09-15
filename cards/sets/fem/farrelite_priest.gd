extends CardScript
## Farrelite Priest — {1}{W}{W} — Creature — Human Cleric — 1/3 — (fem, uncommon)
## Oracle: {1}: Add {W}. If this ability has been activated four or more times this turn, sacrifice this creature at the beginning of the next end step.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Farrelite Priest", "{1}{W}{W}", Mtg.CardType.CREATURE)
	card.pt(1, 3)
	card.with_subtypes(["human", "cleric"])
	card.oracle("{1}: Add {W}. If this ability has been activated four or more times this turn, sacrifice this creature at the beginning of the next end step.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
