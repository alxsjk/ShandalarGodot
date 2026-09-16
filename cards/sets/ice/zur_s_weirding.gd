extends CardScript
## Zur's Weirding — {3}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Zur's Weirding", "{3}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Players play with their hands revealed.\nIf a player would draw a card, they reveal it instead. Then any other player may pay 2 life. If a player does, put that card into its owner's graveyard. Otherwise, that player draws a card.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
