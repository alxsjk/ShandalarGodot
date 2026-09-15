extends CardScript
## Musician — {2}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Musician", "{2}{U}", Mtg.CardType.CREATURE)
	card.pt(1, 3)
	card.with_subtypes(["human","wizard"])
	card.oracle("Cumulative upkeep {1} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\n{T}: Put a music counter on target creature. If it doesn't have \"At the beginning of your upkeep, destroy this creature unless you pay {1} for each music counter on it,\" it gains that ability.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
