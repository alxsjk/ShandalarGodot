extends CardScript
## Elvish Farmer — {1}{G} — Creature — Elf — 0/2 — (fem, rare)
## Oracle: At the beginning of your upkeep, put a spore counter on this creature.
##         Remove three spore counters from this creature: Create a 1/1 green Saproling creature token.
##         Sacrifice a Saproling: You gain 2 life.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Elvish Farmer", "{1}{G}", Mtg.CardType.CREATURE)
	card.pt(0, 2)
	card.with_subtypes(["elf"])
	card.oracle("At the beginning of your upkeep, put a spore counter on this creature.\nRemove three spore counters from this creature: Create a 1/1 green Saproling creature token.\nSacrifice a Saproling: You gain 2 life.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
