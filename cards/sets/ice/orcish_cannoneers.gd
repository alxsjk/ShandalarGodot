extends CardScript
## Orcish Cannoneers — {1}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Orcish Cannoneers", "{1}{R}{R}", Mtg.CardType.CREATURE)
	card.pt(1, 3)
	card.with_subtypes(["orc","warrior"])
	card.oracle("{T}: This creature deals 2 damage to any target and 3 damage to you.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
