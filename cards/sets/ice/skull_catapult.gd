extends CardScript
## Skull Catapult — {4} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Skull Catapult", "{4}", Mtg.CardType.ARTIFACT)
	card.oracle("{1}, {T}, Sacrifice a creature: This artifact deals 2 damage to any target.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
