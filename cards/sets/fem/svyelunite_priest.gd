extends CardScript
## Svyelunite Priest — {1}{U} — Creature — Merfolk Cleric — 1/1 — (fem, uncommon)
## Oracle: {U}{U}, {T}: Target creature gains shroud until end of turn. Activate only during your upkeep. (It can't be the target of spells or abilities.)
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Svyelunite Priest", "{1}{U}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["merfolk", "cleric"])
	card.oracle("{U}{U}, {T}: Target creature gains shroud until end of turn. Activate only during your upkeep. (It can't be the target of spells or abilities.)")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
