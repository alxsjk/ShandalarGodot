extends CardScript
## Dwarven Catapult — {X}{R} — Instant — (fem, uncommon)
## Oracle: Dwarven Catapult deals X damage divided evenly, rounded down, among all creatures target opponent controls.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Dwarven Catapult", "{X}{R}", Mtg.CardType.INSTANT)
	card.oracle("Dwarven Catapult deals X damage divided evenly, rounded down, among all creatures target opponent controls.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
