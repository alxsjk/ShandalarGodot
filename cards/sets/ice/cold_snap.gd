extends CardScript
## Cold Snap — {2}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Cold Snap", "{2}{W}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Cumulative upkeep {2} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nAt the beginning of each player's upkeep, this enchantment deals damage to that player equal to the number of snow lands they control.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
