extends CardScript
## Battle Cry — {2}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Battle Cry", "{2}{W}", Mtg.CardType.INSTANT)
	card.oracle("Untap all white creatures you control.\nWhenever a creature blocks this turn, it gets +0/+1 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
