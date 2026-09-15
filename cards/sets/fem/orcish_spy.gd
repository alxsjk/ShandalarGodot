extends CardScript
## Orcish Spy — {R} — Creature — Orc Rogue — 1/1 — (fem, common)
## Oracle: {T}: Look at the top three cards of target player's library.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Orcish Spy", "{R}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["orc", "rogue"])
	card.oracle("{T}: Look at the top three cards of target player's library.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
