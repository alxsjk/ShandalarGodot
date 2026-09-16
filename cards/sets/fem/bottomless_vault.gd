extends CardScript
## Bottomless Vault — Land — (fem, rare)
## Oracle: This land enters tapped.
##         You may choose not to untap this land during your untap step.
##         At the beginning of your upkeep, if this land is tapped, put a storage counter on it.
##         {T}, Remove any number of storage counters from this land: Add {B} for each storage counter removed this way.
##
## Pack 2 only. Shared patterns are in _rules.gd; no ZIP supplies code.

func build() -> CardData:
	var card := CardData.new("Bottomless Vault", "", Mtg.CardType.LAND)
	card.oracle("This land enters tapped.\nYou may choose not to untap this land during your untap step.\nAt the beginning of your upkeep, if this land is tapped, put a storage counter on it.\n{T}, Remove any number of storage counters from this land: Add {B} for each storage counter removed this way.")
	return load("res://cards/sets/fem/_rules.gd").apply(card)
