extends CardScript
## Icatian Lieutenant — {W}{W} — Creature — Human Soldier — 1/2 — (fem, rare)
## Oracle: {1}{W}: Target Soldier creature gets +1/+0 until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Icatian Lieutenant", "{W}{W}", Mtg.CardType.CREATURE)
	card.pt(1, 2)
	card.with_subtypes(["human", "soldier"])
	card.oracle("{1}{W}: Target Soldier creature gets +1/+0 until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
