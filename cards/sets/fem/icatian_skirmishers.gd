extends CardScript
## Icatian Skirmishers — {3}{W} — Creature — Human Soldier — 1/1 — (fem, rare)
## Oracle: First strike; banding (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)
##         Whenever this creature attacks, all creatures banded with it gain first strike until end of turn.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Icatian Skirmishers", "{3}{W}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human", "soldier"])
	card.with_keywords([Mtg.Keyword.FIRST_STRIKE, Mtg.Keyword.BANDING])
	card.oracle("First strike; banding (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)\nWhenever this creature attacks, all creatures banded with it gain first strike until end of turn.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
