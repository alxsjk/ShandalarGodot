extends CardScript
## Fanatical Fever — {2}{G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Fanatical Fever", "{2}{G}{G}", Mtg.CardType.INSTANT)
	card.oracle("Target creature gets +3/+0 and gains trample until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
