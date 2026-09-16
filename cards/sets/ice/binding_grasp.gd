extends CardScript
## Binding Grasp — {3}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Binding Grasp", "{3}{U}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nAt the beginning of your upkeep, sacrifice this Aura unless you pay {1}{U}.\nYou control enchanted creature.\nEnchanted creature gets +0/+1.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
