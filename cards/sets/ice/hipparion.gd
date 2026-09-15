extends CardScript
## Hipparion — {1}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Hipparion", "{1}{W}", Mtg.CardType.CREATURE)
	card.pt(1, 3)
	card.with_subtypes(["horse"])
	card.oracle("This creature can't block creatures with power 3 or greater unless you pay {1}.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
