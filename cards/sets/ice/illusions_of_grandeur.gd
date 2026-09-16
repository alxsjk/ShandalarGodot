extends CardScript
## Illusions of Grandeur — {3}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Illusions of Grandeur", "{3}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Cumulative upkeep {2} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nWhen this enchantment enters, you gain 20 life.\nWhen this enchantment leaves the battlefield, you lose 20 life.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
