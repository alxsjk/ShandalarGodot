extends CardScript
## Gangrenous Zombies — {1}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Gangrenous Zombies", "{1}{B}{B}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["zombie"])
	card.oracle("{T}, Sacrifice this creature: This creature deals 1 damage to each creature and each player. If you control a snow Swamp, this creature deals 2 damage to each creature and each player instead.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
