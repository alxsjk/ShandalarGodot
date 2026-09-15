extends CardScript
## Hydroblast — {U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Hydroblast", "{U}", Mtg.CardType.INSTANT)
	card.oracle("Choose one —\n• Counter target spell if it's red.\n• Destroy target permanent if it's red.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
