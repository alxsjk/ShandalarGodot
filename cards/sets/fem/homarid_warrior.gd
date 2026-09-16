extends CardScript
## Homarid Warrior — {4}{U} — Creature — Homarid Warrior — 3/3 — (fem, common)
## Oracle: {U}: This creature gains shroud until end of turn and doesn't untap during your next untap step. Tap it. (A creature with shroud can't be the target of spells or abilities.)
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Homarid Warrior", "{4}{U}", Mtg.CardType.CREATURE)
	card.pt(3, 3)
	card.with_subtypes(["homarid", "warrior"])
	card.oracle("{U}: This creature gains shroud until end of turn and doesn't untap during your next untap step. Tap it. (A creature with shroud can't be the target of spells or abilities.)")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
