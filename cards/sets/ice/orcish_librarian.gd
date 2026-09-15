extends CardScript
## Orcish Librarian — {1}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Orcish Librarian", "{1}{R}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["orc"])
	card.oracle("{R}, {T}: Look at the top eight cards of your library. Exile four of them at random, then put the rest on top of your library in any order.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
