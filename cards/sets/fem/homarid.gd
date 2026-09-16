extends CardScript
## Homarid — {2}{U} — Creature — Homarid — 2/2 — (fem, common)
## Oracle: This creature enters with a tide counter on it.
##         At the beginning of your upkeep, put a tide counter on this creature.
##         As long as there is exactly one tide counter on this creature, it gets -1/-1.
##         As long as there are exactly three tide counters on this creature, it gets +1/+1.
##         Whenever there are four or more tide counters on this creature, remove all tide counters from it.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Homarid", "{2}{U}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["homarid"])
	card.oracle("This creature enters with a tide counter on it.\nAt the beginning of your upkeep, put a tide counter on this creature.\nAs long as there is exactly one tide counter on this creature, it gets -1/-1.\nAs long as there are exactly three tide counters on this creature, it gets +1/+1.\nWhenever there are four or more tide counters on this creature, remove all tide counters from it.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
