extends CardScript
## Illusionary Wall — {4}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Illusionary Wall", "{4}{U}", Mtg.CardType.CREATURE)
	card.pt(7, 4)
	card.with_subtypes(["illusion","wall"])
	card.with_keywords([Mtg.Keyword.FLYING, Mtg.Keyword.FIRST_STRIKE, Mtg.Keyword.DEFENDER])
	card.oracle("Defender, flying, first strike\nCumulative upkeep {U} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
