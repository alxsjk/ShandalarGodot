extends CardScript
## Pyroblast — {R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Pyroblast", "{R}", Mtg.CardType.INSTANT)
	card.oracle("Choose one —\n• Counter target spell if it's blue.\n• Destroy target permanent if it's blue.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
