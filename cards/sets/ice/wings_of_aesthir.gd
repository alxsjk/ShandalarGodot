extends CardScript
## Wings of Aesthir — {W}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Wings of Aesthir", "{W}{U}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nEnchanted creature gets +1/+0 and has flying and first strike.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
