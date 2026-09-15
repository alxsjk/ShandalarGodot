extends CardScript
## Snow Devil — {1}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Snow Devil", "{1}{U}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nEnchanted creature has flying.\nEnchanted creature has first strike as long as it's blocking and you control a snow land.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
