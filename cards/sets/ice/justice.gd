extends CardScript
## Justice — {2}{W}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Justice", "{2}{W}{W}", Mtg.CardType.ENCHANTMENT)
	card.oracle("At the beginning of your upkeep, sacrifice this enchantment unless you pay {W}{W}.\nWhenever a red creature or spell deals damage, this enchantment deals that much damage to that creature's or spell's controller.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
