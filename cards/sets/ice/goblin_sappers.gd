extends CardScript
## Goblin Sappers — {1}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Goblin Sappers", "{1}{R}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["goblin"])
	card.oracle("{R}{R}, {T}: Target creature you control can't be blocked this turn. Destroy it and this creature at end of combat.\n{R}{R}{R}{R}, {T}: Target creature you control can't be blocked this turn. Destroy it at end of combat.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
