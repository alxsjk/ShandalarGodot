extends CardScript
## Centaur Archer — {1}{R}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Centaur Archer", "{1}{R}{G}", Mtg.CardType.CREATURE)
	card.pt(3, 2)
	card.with_subtypes(["centaur","archer"])
	card.oracle("{T}: This creature deals 1 damage to target creature with flying.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
