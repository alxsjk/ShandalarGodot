extends CardScript
## Flow of Maggots — {2}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Flow of Maggots", "{2}{B}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["insect"])
	card.oracle("Cumulative upkeep {1} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nThis creature can't be blocked by non-Wall creatures.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
