extends CardScript
## Woolly Spider — {1}{G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Woolly Spider", "{1}{G}{G}", Mtg.CardType.CREATURE)
	card.pt(2, 3)
	card.with_subtypes(["spider"])
	card.with_keywords([Mtg.Keyword.REACH])
	card.oracle("Reach (This creature can block creatures with flying.)\nWhenever this creature blocks a creature with flying, this creature gets +0/+2 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
