extends CardScript
## Mercenaries — {3}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Mercenaries", "{3}{W}", Mtg.CardType.CREATURE)
	card.pt(3, 3)
	card.with_subtypes(["human","mercenary"])
	card.oracle("{3}: The next time this creature would deal damage to you this turn, prevent that damage. Any player may activate this ability.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
