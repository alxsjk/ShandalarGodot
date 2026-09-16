extends CardScript
## Goblin Flotilla — {2}{R} — Creature — Goblin — 2/2 — (fem, rare)
## Oracle: Islandwalk (This creature can't be blocked as long as defending player controls an Island.)
##         At the beginning of each combat, unless you pay {R}, whenever this creature blocks or becomes blocked by a creature this combat, that creature gains first strike until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Goblin Flotilla", "{2}{R}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["goblin"])
	card.with_landwalk(["island"])
	card.oracle("Islandwalk (This creature can't be blocked as long as defending player controls an Island.)\nAt the beginning of each combat, unless you pay {R}, whenever this creature blocks or becomes blocked by a creature this combat, that creature gains first strike until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
