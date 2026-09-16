extends CardScript
## Chromatic Armor — {1}{W}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Chromatic Armor", "{1}{W}{U}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nAs this Aura enters, choose a color.\nThis Aura enters with a sleight counter on it.\nPrevent all damage that would be dealt to enchanted creature by sources of the last chosen color.\n{X}: Put a sleight counter on this Aura and choose a color. X is the number of sleight counters on this Aura.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
