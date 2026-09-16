extends CardScript
## Conquer — {3}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Conquer", "{3}{R}{R}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant land\nYou control enchanted land.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
