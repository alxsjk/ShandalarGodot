extends CardScript
## Hand of Justice — {5}{W} — Creature — Avatar — 2/6 — (fem, rare)
## Oracle: {T}, Tap three untapped white creatures you control: Destroy target creature.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Hand of Justice", "{5}{W}", Mtg.CardType.CREATURE)
	card.pt(2, 6)
	card.with_subtypes(["avatar"])
	card.oracle("{T}, Tap three untapped white creatures you control: Destroy target creature.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
