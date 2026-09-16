extends CardScript
## Mind Whip — {2}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Mind Whip", "{2}{B}{B}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nAt the beginning of the upkeep of enchanted creature's controller, that player may pay {3}. If they don't, this Aura deals 2 damage to that player and you tap that creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
