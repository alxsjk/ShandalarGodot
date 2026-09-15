extends CardScript
## Prismatic Ward — {1}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Prismatic Ward", "{1}{W}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nAs this Aura enters, choose a color.\nPrevent all damage that would be dealt to enchanted creature by sources of the chosen color.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
