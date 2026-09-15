extends CardScript
## Moor Fiend — {3}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Moor Fiend", "{3}{B}", Mtg.CardType.CREATURE)
	card.pt(3, 3)
	card.with_subtypes(["horror"])
	card.with_landwalk(["swamp"])
	card.oracle("Swampwalk (This creature can't be blocked as long as defending player controls a Swamp.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
