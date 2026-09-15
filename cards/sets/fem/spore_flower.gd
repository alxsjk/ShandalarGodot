extends CardScript
## Spore Flower — {G}{G} — Creature — Fungus — 0/1 — (fem, uncommon)
## Oracle: At the beginning of your upkeep, put a spore counter on this creature.
##         Remove three spore counters from this creature: Prevent all combat damage that would be dealt this turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Spore Flower", "{G}{G}", Mtg.CardType.CREATURE)
	card.pt(0, 1)
	card.with_subtypes(["fungus"])
	card.oracle("At the beginning of your upkeep, put a spore counter on this creature.\nRemove three spore counters from this creature: Prevent all combat damage that would be dealt this turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
