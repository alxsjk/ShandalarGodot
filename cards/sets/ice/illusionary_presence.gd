extends CardScript
## Illusionary Presence — {1}{U}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Illusionary Presence", "{1}{U}{U}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["illusion"])
	card.oracle("Cumulative upkeep {U} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nAt the beginning of your upkeep, choose a land type. This creature gains landwalk of the chosen type until end of turn. (It can't be blocked as long as defending player controls a land of that type.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
