extends CardScript
## Infernal Darkness — {2}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Infernal Darkness", "{2}{B}{B}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Cumulative upkeep—Pay {B} and 1 life. (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nIf a land is tapped for mana, it produces {B} instead of any other type.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
