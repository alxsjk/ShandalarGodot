extends CardScript
## Combat Medic — {2}{W} — Creature — Human Cleric Soldier — 0/2 — (fem, common)
## Oracle: {1}{W}: Prevent the next 1 damage that would be dealt to any target this turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Combat Medic", "{2}{W}", Mtg.CardType.CREATURE)
	card.pt(0, 2)
	card.with_subtypes(["human", "cleric", "soldier"])
	card.oracle("{1}{W}: Prevent the next 1 damage that would be dealt to any target this turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
