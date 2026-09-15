extends CardScript
## Sacred Boon — {1}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Sacred Boon", "{1}{W}", Mtg.CardType.INSTANT)
	card.oracle("Prevent the next 3 damage that would be dealt to target creature this turn. At the beginning of the next end step, put a +0/+1 counter on that creature for each 1 damage prevented this way.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
