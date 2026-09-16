extends CardScript
## Forbidden Lore — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Forbidden Lore", "{2}{G}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant land\nEnchanted land has \"{T}: Target creature gets +2/+1 until end of turn.\"")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
