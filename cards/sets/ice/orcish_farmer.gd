extends CardScript
## Orcish Farmer — {1}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Orcish Farmer", "{1}{R}{R}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["orc"])
	card.oracle("{T}: Target land becomes a Swamp until its controller's next untap step.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
