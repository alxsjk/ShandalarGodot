extends CardScript
## Feral Thallid — {3}{G}{G}{G} — Creature — Fungus — 6/3 — (fem, uncommon)
## Oracle: At the beginning of your upkeep, put a spore counter on this creature.
##         Remove three spore counters from this creature: Regenerate this creature.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Feral Thallid", "{3}{G}{G}{G}", Mtg.CardType.CREATURE)
	card.pt(6, 3)
	card.with_subtypes(["fungus"])
	card.oracle("At the beginning of your upkeep, put a spore counter on this creature.\nRemove three spore counters from this creature: Regenerate this creature.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
