extends CardScript
## Arctic Foxes — {1}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Arctic Foxes", "{1}{W}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["fox"])
	card.oracle("This creature can't be blocked by creatures with power 2 or greater as long as defending player controls a snow land.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
