extends CardScript
## Elvish Hunter — {1}{G} — Creature — Elf Archer — 1/1 — (fem, common)
## Oracle: {1}{G}, {T}: Target creature doesn't untap during its controller's next untap step.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Elvish Hunter", "{1}{G}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["elf", "archer"])
	card.oracle("{1}{G}, {T}: Target creature doesn't untap during its controller's next untap step.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
