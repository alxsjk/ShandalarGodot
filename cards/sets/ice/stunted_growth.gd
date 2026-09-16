extends CardScript
## Stunted Growth — {3}{G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Stunted Growth", "{3}{G}{G}", Mtg.CardType.SORCERY)
	card.oracle("Target player chooses three cards from their hand and puts them on top of their library in any order.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
