extends CardScript
## Fyndhorn Pollen — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Fyndhorn Pollen", "{2}{G}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Cumulative upkeep {1} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nAll creatures get -1/-0.\n{1}{G}: All creatures get -1/-0 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
