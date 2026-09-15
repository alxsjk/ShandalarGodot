extends CardScript
## Hot Springs — {1}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Hot Springs", "{1}{G}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant land you control\nEnchanted land has \"{T}: Prevent the next 1 damage that would be dealt to any target this turn.\"")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
