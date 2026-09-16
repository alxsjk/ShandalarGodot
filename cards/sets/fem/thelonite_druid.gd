extends CardScript
## Thelonite Druid — {2}{G} — Creature — Human Cleric Druid — 1/1 — (fem, uncommon)
## Oracle: {1}{G}, {T}, Sacrifice a creature: Forests you control become 2/3 creatures until end of turn. They're still lands.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Thelonite Druid", "{2}{G}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human", "cleric", "druid"])
	card.oracle("{1}{G}, {T}, Sacrifice a creature: Forests you control become 2/3 creatures until end of turn. They're still lands.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
