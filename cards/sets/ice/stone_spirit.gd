extends CardScript
## Stone Spirit — {4}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Stone Spirit", "{4}{R}", Mtg.CardType.CREATURE)
	card.pt(4, 3)
	card.with_subtypes(["elemental","spirit"])
	card.oracle("This creature can't be blocked by creatures with flying.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
