extends CardScript
## Homarid Shaman — {2}{U}{U} — Creature — Homarid Shaman — 2/1 — (fem, rare)
## Oracle: {U}: Tap target green creature.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Homarid Shaman", "{2}{U}{U}", Mtg.CardType.CREATURE)
	card.pt(2, 1)
	card.with_subtypes(["homarid", "shaman"])
	card.oracle("{U}: Tap target green creature.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
