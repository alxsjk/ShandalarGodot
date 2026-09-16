extends CardScript
## Thoughtleech — {G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Thoughtleech", "{G}{G}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Whenever an Island an opponent controls becomes tapped, you may gain 1 life.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
