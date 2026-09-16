extends CardScript
## Minion of Tevesh Szat — {4}{B}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Minion of Tevesh Szat", "{4}{B}{B}{B}", Mtg.CardType.CREATURE)
	card.pt(4, 4)
	card.with_subtypes(["demon","minion"])
	card.oracle("At the beginning of your upkeep, this creature deals 2 damage to you unless you pay {B}{B}.\n{T}: Target creature gets +3/-2 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
