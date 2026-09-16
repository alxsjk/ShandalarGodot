extends CardScript
## Errant Minion — {2}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Errant Minion", "{2}{U}", Mtg.CardType.ENCHANTMENT)
	card.with_subtypes(["aura"])
	card.oracle("Enchant creature\nAt the beginning of the upkeep of enchanted creature's controller, that player may pay any amount of mana. This Aura deals 2 damage to that player. Prevent X of that damage, where X is the amount of mana that player paid this way.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
