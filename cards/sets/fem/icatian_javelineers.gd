extends CardScript
## Icatian Javelineers — {W} — Creature — Human Soldier — 1/1 — (fem, common)
## Oracle: This creature enters with a javelin counter on it.
##         {T}, Remove a javelin counter from this creature: It deals 1 damage to any target.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Icatian Javelineers", "{W}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human", "soldier"])
	card.oracle("This creature enters with a javelin counter on it.\n{T}, Remove a javelin counter from this creature: It deals 1 damage to any target.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
