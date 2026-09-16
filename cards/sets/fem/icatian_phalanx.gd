extends CardScript
## Icatian Phalanx — {4}{W} — Creature — Human Soldier — 2/4 — (fem, uncommon)
## Oracle: Banding (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Icatian Phalanx", "{4}{W}", Mtg.CardType.CREATURE)
	card.pt(2, 4)
	card.with_subtypes(["human", "soldier"])
	card.with_keywords([Mtg.Keyword.BANDING])
	card.oracle("Banding (Any creatures with banding, and up to one without, can attack in a band. Bands are blocked as a group. If any creatures with banding you control are blocking or being blocked by a creature, you divide that creature's combat damage, not its controller, among any of the creatures it's being blocked by or is blocking.)")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
