extends CardScript
## Earthlink — {3}{B}{R}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Earthlink", "{3}{B}{R}{G}", Mtg.CardType.ENCHANTMENT)
	card.oracle("At the beginning of your upkeep, sacrifice this enchantment unless you pay {2}.\nWhenever a creature dies, that creature's controller sacrifices a land of their choice.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
