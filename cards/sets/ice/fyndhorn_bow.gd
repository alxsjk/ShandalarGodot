extends CardScript
## Fyndhorn Bow — {2} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Fyndhorn Bow", "{2}", Mtg.CardType.ARTIFACT)
	card.oracle("{3}, {T}: Target creature gains first strike until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
