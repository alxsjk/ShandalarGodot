extends CardScript
## Orcish Conscripts — {R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Orcish Conscripts", "{R}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["orc"])
	card.oracle("This creature can't attack unless at least two other creatures attack.\nThis creature can't block unless at least two other creatures block.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
