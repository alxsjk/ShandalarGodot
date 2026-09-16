extends CardScript
## Mudslide — {2}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Mudslide", "{2}{R}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Creatures without flying don't untap during their controllers' untap steps.\nAt the beginning of each player's upkeep, that player may choose any number of tapped creatures without flying they control and pay {2} for each creature chosen this way. If the player does, untap those creatures.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
