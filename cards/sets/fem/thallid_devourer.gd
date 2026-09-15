extends CardScript
## Thallid Devourer — {1}{G}{G} — Creature — Fungus — 2/2 — (fem, uncommon)
## Oracle: At the beginning of your upkeep, put a spore counter on this creature.
##         Remove three spore counters from this creature: Create a 1/1 green Saproling creature token.
##         Sacrifice a Saproling: This creature gets +1/+2 until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Thallid Devourer", "{1}{G}{G}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["fungus"])
	card.oracle("At the beginning of your upkeep, put a spore counter on this creature.\nRemove three spore counters from this creature: Create a 1/1 green Saproling creature token.\nSacrifice a Saproling: This creature gets +1/+2 until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
