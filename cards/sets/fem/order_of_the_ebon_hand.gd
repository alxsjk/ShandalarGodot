extends CardScript
## Order of the Ebon Hand — {B}{B} — Creature — Cleric Knight — 2/1 — (fem, common)
## Oracle: Protection from white
##         {B}: This creature gains first strike until end of turn.
##         {B}{B}: This creature gets +1/+0 until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Order of the Ebon Hand", "{B}{B}", Mtg.CardType.CREATURE)
	card.pt(2, 1)
	card.with_subtypes(["cleric", "knight"])
	card.with_protection_from(Mtg.ManaColor.W)
	card.oracle("Protection from white\n{B}: This creature gains first strike until end of turn.\n{B}{B}: This creature gets +1/+0 until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
