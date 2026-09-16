extends CardScript
## Icatian Priest — {W} — Creature — Human Cleric — 1/1 — (fem, uncommon)
## Oracle: {1}{W}{W}: Target creature gets +1/+1 until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Icatian Priest", "{W}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human", "cleric"])
	card.oracle("{1}{W}{W}: Target creature gets +1/+1 until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
