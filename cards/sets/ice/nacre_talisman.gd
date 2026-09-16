extends CardScript
## Nacre Talisman — {2} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Nacre Talisman", "{2}", Mtg.CardType.ARTIFACT)
	card.oracle("Whenever a player casts a white spell, you may pay {3}. If you do, untap target permanent.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
