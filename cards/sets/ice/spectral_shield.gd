extends CardScript
## Spectral Shield — {1}{W}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Spectral Shield", "{1}{W}{U}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nEnchanted creature gets +0/+2 and can't be the target of spells.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
