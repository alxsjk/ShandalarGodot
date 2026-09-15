extends CardScript
## Mesmeric Trance — {1}{U}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Mesmeric Trance", "{1}{U}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Cumulative upkeep {1} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\n{U}, Discard a card: Draw a card.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
