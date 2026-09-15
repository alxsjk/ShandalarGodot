extends CardScript
## Seizures — {1}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Seizures", "{1}{B}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nWhenever enchanted creature becomes tapped, this Aura deals 3 damage to that creature's controller unless that player pays {3}.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
