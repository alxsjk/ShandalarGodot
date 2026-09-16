extends CardScript
## Thorn Thallid — {1}{G}{G} — Creature — Fungus — 2/2 — (fem, common)
## Oracle: At the beginning of your upkeep, put a spore counter on this creature.
##         Remove three spore counters from this creature: It deals 1 damage to any target.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Thorn Thallid", "{1}{G}{G}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["fungus"])
	card.oracle("At the beginning of your upkeep, put a spore counter on this creature.\nRemove three spore counters from this creature: It deals 1 damage to any target.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
