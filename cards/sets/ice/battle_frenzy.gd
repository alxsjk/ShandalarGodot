extends CardScript
## Battle Frenzy — {2}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Battle Frenzy", "{2}{R}", Mtg.CardType.INSTANT)
	card.oracle("Green creatures you control get +1/+1 until end of turn.\nNongreen creatures you control get +1/+0 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
