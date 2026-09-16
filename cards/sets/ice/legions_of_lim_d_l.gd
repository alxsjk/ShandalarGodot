extends CardScript
## Legions of Lim-Dûl — {1}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Legions of Lim-Dûl", "{1}{B}{B}", Mtg.CardType.CREATURE)
	card.pt(2, 3)
	card.with_subtypes(["zombie"])
	card.with_landwalk(["snow swamp"])
	card.oracle("Snow swampwalk (This creature can't be blocked as long as defending player controls a snow Swamp.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
