extends CardScript
## Reality Twist — {U}{U}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Reality Twist", "{U}{U}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Cumulative upkeep {1}{U}{U} (At the beginning of your upkeep, put an age counter on this permanent, then sacrifice it unless you pay its upkeep cost for each age counter on it.)\nIf tapped for mana, Plains produce {R}, Swamps produce {G}, Mountains produce {W}, and Forests produce {B} instead of any other type.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
