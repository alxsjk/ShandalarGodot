extends CardScript
## Errantry — {1}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Errantry", "{1}{R}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nEnchanted creature gets +3/+0 and can only attack alone.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
