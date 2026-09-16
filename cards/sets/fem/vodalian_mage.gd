extends CardScript
## Vodalian Mage — {2}{U} — Creature — Merfolk Wizard — 1/1 — (fem, common)
## Oracle: {U}, {T}: Counter target spell unless its controller pays {1}.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Vodalian Mage", "{2}{U}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["merfolk", "wizard"])
	card.oracle("{U}, {T}: Counter target spell unless its controller pays {1}.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
