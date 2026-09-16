extends CardScript
## Lava Burst — {X}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Lava Burst", "{X}{R}", Mtg.CardType.SORCERY)
	card.oracle("Lava Burst deals X damage to any target. If Lava Burst would deal damage to a creature, that damage can't be prevented or dealt instead to another permanent or player.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
