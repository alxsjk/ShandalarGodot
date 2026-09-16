extends CardScript
## Barbed Sextant — {1} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Barbed Sextant", "{1}", Mtg.CardType.ARTIFACT)
	card.oracle("{1}, {T}, Sacrifice this artifact: Add one mana of any color. Draw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
