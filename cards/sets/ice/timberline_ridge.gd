extends CardScript
## Timberline Ridge — no mana cost — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Timberline Ridge", "", Mtg.CardType.LAND)
	card.oracle("This land doesn't untap during your untap step if it has a depletion counter on it.\nAt the beginning of your upkeep, remove a depletion counter from this land.\n{T}: Add {R} or {G}. Put a depletion counter on this land.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
