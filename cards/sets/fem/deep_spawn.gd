extends CardScript
## Deep Spawn — {5}{U}{U}{U} — Creature — Homarid — 6/6 — (fem, uncommon)
## Oracle: Trample
##         At the beginning of your upkeep, sacrifice this creature unless you mill two cards.
##         {U}: This creature gains shroud until end of turn and doesn't untap during your next untap step. Tap this creature. (A creature with shroud can't be the target of spells or abilities.)
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Deep Spawn", "{5}{U}{U}{U}", Mtg.CardType.CREATURE)
	card.pt(6, 6)
	card.with_subtypes(["homarid"])
	card.with_keywords([Mtg.Keyword.TRAMPLE])
	card.oracle("Trample\nAt the beginning of your upkeep, sacrifice this creature unless you mill two cards.\n{U}: This creature gains shroud until end of turn and doesn't untap during your next untap step. Tap this creature. (A creature with shroud can't be the target of spells or abilities.)")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
