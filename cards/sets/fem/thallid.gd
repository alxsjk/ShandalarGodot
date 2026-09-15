extends CardScript
## Thallid — {G} — Creature — Fungus — 1/1 — (fem, common)
## Oracle: At the beginning of your upkeep, put a spore counter on this creature.
##         Remove three spore counters from this creature: Create a 1/1 green Saproling creature token.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Thallid", "{G}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["fungus"])
	card.oracle("At the beginning of your upkeep, put a spore counter on this creature.\nRemove three spore counters from this creature: Create a 1/1 green Saproling creature token.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
