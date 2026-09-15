extends CardScript
## Burnt Offering — {B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Burnt Offering", "{B}", Mtg.CardType.INSTANT)
	card.oracle("As an additional cost to cast this spell, sacrifice a creature.\nAdd X mana in any combination of {B} and/or {R}, where X is the sacrificed creature's mana value.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
