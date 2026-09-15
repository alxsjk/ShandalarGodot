extends CardScript
## Mountain Goat — {R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Mountain Goat", "{R}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["goat"])
	card.with_landwalk(["mountain"])
	card.oracle("Mountainwalk (This creature can't be blocked as long as defending player controls a Mountain.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
