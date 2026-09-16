extends CardScript
## Minion of Leshrac — {4}{B}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Minion of Leshrac", "{4}{B}{B}{B}", Mtg.CardType.CREATURE)
	card.pt(5, 5)
	card.with_subtypes(["demon","minion"])
	card.with_protection_from(Mtg.ManaColor.B)
	card.oracle("Protection from black\nAt the beginning of your upkeep, this creature deals 5 damage to you unless you sacrifice a creature other than this creature. If this creature deals damage to you this way, tap it.\n{T}: Destroy target creature or land.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
