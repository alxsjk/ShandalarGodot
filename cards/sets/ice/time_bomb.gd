extends CardScript
## Time Bomb — {4} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Time Bomb", "{4}", Mtg.CardType.ARTIFACT)
	card.oracle("At the beginning of your upkeep, put a time counter on this artifact.\n{1}, {T}, Sacrifice this artifact: This artifact deals damage equal to the number of time counters on it to each creature and each player.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
