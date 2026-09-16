extends CardScript
## White Scarab — {W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("White Scarab", "{W}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nEnchanted creature can't be blocked by white creatures.\nEnchanted creature gets +2/+2 as long as an opponent controls a white permanent.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
