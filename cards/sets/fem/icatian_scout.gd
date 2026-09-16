extends CardScript
## Icatian Scout — {W} — Creature — Human Soldier Scout — 1/1 — (fem, common)
## Oracle: {1}, {T}: Target creature gains first strike until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Icatian Scout", "{W}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human", "soldier", "scout"])
	card.oracle("{1}, {T}: Target creature gains first strike until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
