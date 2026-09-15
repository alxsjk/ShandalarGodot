extends CardScript
## Necrite — {1}{B}{B} — Creature — Thrull — 2/2 — (fem, common)
## Oracle: Whenever this creature attacks and isn't blocked, you may sacrifice it. If you do, destroy target creature defending player controls. It can't be regenerated.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Necrite", "{1}{B}{B}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["thrull"])
	card.oracle("Whenever this creature attacks and isn't blocked, you may sacrifice it. If you do, destroy target creature defending player controls. It can't be regenerated.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
