extends CardScript
## Icatian Moneychanger — {W} — Creature — Human — 0/2 — (fem, common)
## Oracle: This creature enters with three credit counters on it.
##         When this creature enters, it deals 3 damage to you.
##         At the beginning of your upkeep, put a credit counter on this creature.
##         Sacrifice this creature: You gain 1 life for each credit counter on this creature. Activate only during your upkeep.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Icatian Moneychanger", "{W}", Mtg.CardType.CREATURE)
	card.pt(0, 2)
	card.with_subtypes(["human"])
	card.oracle("This creature enters with three credit counters on it.\nWhen this creature enters, it deals 3 damage to you.\nAt the beginning of your upkeep, put a credit counter on this creature.\nSacrifice this creature: You gain 1 life for each credit counter on this creature. Activate only during your upkeep.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
