extends CardScript
## Imposing Visage — {R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Imposing Visage", "{R}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nEnchanted creature has menace. (It can't be blocked except by two or more creatures.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
