extends CardScript
## Stampede — {1}{G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Stampede", "{1}{G}{G}", Mtg.CardType.INSTANT)
	card.oracle("Attacking creatures get +1/+0 and gain trample until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
