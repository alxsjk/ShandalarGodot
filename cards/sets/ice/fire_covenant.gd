extends CardScript
## Fire Covenant — {1}{B}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Fire Covenant", "{1}{B}{R}", Mtg.CardType.INSTANT)
	card.oracle("As an additional cost to cast this spell, pay X life.\nFire Covenant deals X damage divided as you choose among any number of target creatures.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
