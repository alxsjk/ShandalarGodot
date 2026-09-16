extends CardScript
## Orcish Veteran — {2}{R} — Creature — Orc — 2/2 — (fem, common)
## Oracle: This creature can't block white creatures with power 2 or greater.
##         {R}: This creature gains first strike until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Orcish Veteran", "{2}{R}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["orc"])
	card.oracle("This creature can't block white creatures with power 2 or greater.\n{R}: This creature gains first strike until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
