extends CardScript
## Grizzled Wolverine — {1}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Grizzled Wolverine", "{1}{R}{R}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["wolverine"])
	card.oracle("{R}: This creature gets +2/+0 until end of turn. Activate only during the declare blockers step, only if at least one creature is blocking this creature, and only once each turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
