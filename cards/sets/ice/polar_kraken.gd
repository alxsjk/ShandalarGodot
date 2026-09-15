extends CardScript
## Polar Kraken — {8}{U}{U}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Polar Kraken", "{8}{U}{U}{U}", Mtg.CardType.CREATURE)
	card.pt(11, 11)
	card.with_subtypes(["kraken"])
	card.with_keywords([Mtg.Keyword.TRAMPLE])
	card.oracle("Trample\nThis creature enters tapped.\nCumulative upkeep—Sacrifice a land. (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
