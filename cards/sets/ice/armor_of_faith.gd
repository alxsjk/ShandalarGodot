extends CardScript
## Armor of Faith — {W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Armor of Faith", "{W}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nEnchanted creature gets +1/+1.\n{W}: Enchanted creature gets +0/+1 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
