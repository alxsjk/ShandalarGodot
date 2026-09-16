extends CardScript
## Pygmy Allosaurus — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Pygmy Allosaurus", "{2}{G}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["dinosaur"])
	card.with_landwalk(["swamp"])
	card.oracle("Swampwalk (This creature can't be blocked as long as defending player controls a Swamp.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
