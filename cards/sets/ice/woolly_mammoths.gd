extends CardScript
## Woolly Mammoths — {1}{G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Woolly Mammoths", "{1}{G}{G}", Mtg.CardType.CREATURE)
	card.pt(3, 2)
	card.with_subtypes(["elephant"])
	card.oracle("This creature has trample as long as you control a snow land.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
