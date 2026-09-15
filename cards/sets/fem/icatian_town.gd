extends CardScript
## Icatian Town — {5}{W} — Sorcery — (fem, rare)
## Oracle: Create four 1/1 white Citizen creature tokens.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Icatian Town", "{5}{W}", Mtg.CardType.SORCERY)
	card.oracle("Create four 1/1 white Citizen creature tokens.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
