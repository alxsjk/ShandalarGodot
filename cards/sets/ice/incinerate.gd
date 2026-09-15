extends CardScript
## Incinerate — {1}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Incinerate", "{1}{R}", Mtg.CardType.INSTANT)
	card.oracle("Incinerate deals 3 damage to any target. A creature dealt damage this way can't be regenerated this turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
