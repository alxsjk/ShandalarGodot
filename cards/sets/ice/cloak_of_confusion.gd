extends CardScript
## Cloak of Confusion — {1}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Cloak of Confusion", "{1}{B}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature you control\nWhenever enchanted creature attacks and isn't blocked, you may have it assign no combat damage this turn. If you do, defending player discards a card at random.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
