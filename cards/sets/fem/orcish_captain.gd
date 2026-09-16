extends CardScript
## Orcish Captain — {R} — Creature — Orc Warrior — 1/1 — (fem, uncommon)
## Oracle: {1}: Flip a coin. If you win the flip, target Orc creature gets +2/+0 until end of turn. If you lose the flip, it gets -0/-2 until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Orcish Captain", "{R}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["orc", "warrior"])
	card.oracle("{1}: Flip a coin. If you win the flip, target Orc creature gets +2/+0 until end of turn. If you lose the flip, it gets -0/-2 until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
