extends CardScript
## Flooded Woodlands — {2}{U}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Flooded Woodlands", "{2}{U}{B}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Green creatures can't attack unless their controller sacrifices a land of their choice for each green creature they control that's attacking. (This cost is paid as attackers are declared.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
