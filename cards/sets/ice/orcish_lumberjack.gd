extends CardScript
## Orcish Lumberjack — {R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Orcish Lumberjack", "{R}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["orc"])
	card.oracle("{T}, Sacrifice a Forest: Add three mana in any combination of {R} and/or {G}.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
