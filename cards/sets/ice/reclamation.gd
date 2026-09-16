extends CardScript
## Reclamation — {2}{G}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Reclamation", "{2}{G}{W}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Black creatures can't attack unless their controller sacrifices a land of their choice for each black creature they control that's attacking. (This cost is paid as attackers are declared.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
