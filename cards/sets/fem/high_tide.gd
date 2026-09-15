extends CardScript
## High Tide — {U} — Instant — (fem, common)
## Oracle: Until end of turn, whenever a player taps an Island for mana, that player adds an additional {U}.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("High Tide", "{U}", Mtg.CardType.INSTANT)
	card.oracle("Until end of turn, whenever a player taps an Island for mana, that player adds an additional {U}.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
