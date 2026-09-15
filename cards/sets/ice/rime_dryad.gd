extends CardScript
## Rime Dryad — {G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Rime Dryad", "{G}", Mtg.CardType.CREATURE)
	card.pt(1, 2)
	card.with_subtypes(["dryad"])
	card.with_landwalk(["snow forest"])
	card.oracle("Snow forestwalk (This creature can't be blocked as long as defending player controls a snow Forest.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
