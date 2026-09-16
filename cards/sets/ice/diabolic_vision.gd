extends CardScript
## Diabolic Vision — {U}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Diabolic Vision", "{U}{B}", Mtg.CardType.SORCERY)
	card.oracle("Look at the top five cards of your library. Put one of them into your hand and the rest on top of your library in any order.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
