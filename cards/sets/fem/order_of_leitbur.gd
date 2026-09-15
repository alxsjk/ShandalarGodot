extends CardScript
## Order of Leitbur — {W}{W} — Creature — Human Cleric Knight — 2/1 — (fem, common)
## Oracle: Protection from black
##         {W}: This creature gains first strike until end of turn.
##         {W}{W}: This creature gets +1/+0 until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Order of Leitbur", "{W}{W}", Mtg.CardType.CREATURE)
	card.pt(2, 1)
	card.with_subtypes(["human", "cleric", "knight"])
	card.with_protection_from(Mtg.ManaColor.B)
	card.oracle("Protection from black\n{W}: This creature gains first strike until end of turn.\n{W}{W}: This creature gets +1/+0 until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
