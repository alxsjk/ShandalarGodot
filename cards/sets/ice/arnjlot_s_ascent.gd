extends CardScript
## Arnjlot's Ascent — {1}{U}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Arnjlot's Ascent", "{1}{U}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Cumulative upkeep {U} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\n{1}: Target creature gains flying until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
