extends CardScript
## Word of Blasting — {1}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Word of Blasting", "{1}{R}", Mtg.CardType.INSTANT)
	card.oracle("Destroy target Wall. It can't be regenerated. Word of Blasting deals damage equal to that Wall's mana value to the Wall's controller.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
