extends CardScript
## River Merfolk — {U}{U} — Creature — Merfolk — 2/1 — (fem, rare)
## Oracle: {U}: This creature gains mountainwalk until end of turn. (It can't be blocked as long as defending player controls a Mountain.)
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("River Merfolk", "{U}{U}", Mtg.CardType.CREATURE)
	card.pt(2, 1)
	card.with_subtypes(["merfolk"])
	card.oracle("{U}: This creature gains mountainwalk until end of turn. (It can't be blocked as long as defending player controls a Mountain.)")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
