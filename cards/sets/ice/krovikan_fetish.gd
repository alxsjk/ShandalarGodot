extends CardScript
## Krovikan Fetish — {2}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Krovikan Fetish", "{2}{B}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nWhen this Aura enters, draw a card at the beginning of the next turn's upkeep.\nEnchanted creature gets +1/+1.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
