extends CardScript
## Ebon Praetor — {4}{B}{B} — Creature — Avatar Praetor — 5/5 — (fem, rare)
## Oracle: First strike, trample
##         At the beginning of your upkeep, put a -2/-2 counter on this creature.
##         Sacrifice a creature: Remove a -2/-2 counter from this creature. If the sacrificed creature was a Thrull, put a +1/+0 counter on this creature. Activate only during your upkeep and only once each turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Ebon Praetor", "{4}{B}{B}", Mtg.CardType.CREATURE)
	card.pt(5, 5)
	card.with_subtypes(["avatar", "praetor"])
	card.with_keywords([Mtg.Keyword.FIRST_STRIKE, Mtg.Keyword.TRAMPLE])
	card.oracle("First strike, trample\nAt the beginning of your upkeep, put a -2/-2 counter on this creature.\nSacrifice a creature: Remove a -2/-2 counter from this creature. If the sacrificed creature was a Thrull, put a +1/+0 counter on this creature. Activate only during your upkeep and only once each turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
