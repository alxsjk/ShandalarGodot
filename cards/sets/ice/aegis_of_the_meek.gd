extends CardScript
## Aegis of the Meek — {3} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Aegis of the Meek", "{3}", Mtg.CardType.ARTIFACT)
	card.oracle("{1}, {T}: Target 1/1 creature gets +1/+2 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
