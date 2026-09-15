extends CardScript
## Hallowed Ground — {1}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Hallowed Ground", "{1}{W}", Mtg.CardType.ENCHANTMENT)
	card.oracle("{W}{W}: Return target nonsnow land you control to its owner's hand.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
