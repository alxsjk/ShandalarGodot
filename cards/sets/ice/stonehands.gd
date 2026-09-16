extends CardScript
## Stonehands — {2}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Stonehands", "{2}{R}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nEnchanted creature gets +0/+2.\n{R}: Enchanted creature gets +1/+0 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
