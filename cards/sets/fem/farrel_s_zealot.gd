extends CardScript
## Farrel's Zealot — {1}{W}{W} — Creature — Human — 2/2 — (fem, common)
## Oracle: Whenever this creature attacks and isn't blocked, you may have it deal 3 damage to target creature. If you do, this creature assigns no combat damage this turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Farrel's Zealot", "{1}{W}{W}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["human"])
	card.oracle("Whenever this creature attacks and isn't blocked, you may have it deal 3 damage to target creature. If you do, this creature assigns no combat damage this turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
