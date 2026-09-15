extends CardScript
## Brainstorm — {U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Brainstorm", "{U}", Mtg.CardType.INSTANT)
	card.oracle("Draw three cards, then put two cards from your hand on top of your library in any order.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
