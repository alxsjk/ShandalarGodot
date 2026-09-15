extends CardScript
## Balduvian Barbarians — {1}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Balduvian Barbarians", "{1}{R}{R}", Mtg.CardType.CREATURE)
	card.pt(3, 2)
	card.with_subtypes(["human","barbarian"])
	card.oracle("")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
