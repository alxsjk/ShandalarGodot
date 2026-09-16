extends CardScript
## Monsoon — {2}{R}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Monsoon", "{2}{R}{G}", Mtg.CardType.ENCHANTMENT)
	card.oracle("At the beginning of each player's end step, tap all untapped Islands that player controls and this enchantment deals X damage to the player, where X is the number of Islands tapped this way.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
