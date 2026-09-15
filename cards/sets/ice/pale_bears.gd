extends CardScript
## Pale Bears — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Pale Bears", "{2}{G}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["bear"])
	card.with_landwalk(["island"])
	card.oracle("Islandwalk (This creature can't be blocked as long as defending player controls an Island.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
