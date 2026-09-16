extends CardScript
## Orgg — {3}{R}{R} — Creature — Orgg — 6/6 — (fem, rare)
## Oracle: Trample
##         This creature can't attack if defending player controls an untapped creature with power 3 or greater.
##         This creature can't block creatures with power 3 or greater.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Orgg", "{3}{R}{R}", Mtg.CardType.CREATURE)
	card.pt(6, 6)
	card.with_subtypes(["orgg"])
	card.with_keywords([Mtg.Keyword.TRAMPLE])
	card.oracle("Trample\nThis creature can't attack if defending player controls an untapped creature with power 3 or greater.\nThis creature can't block creatures with power 3 or greater.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
