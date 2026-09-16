extends CardScript
## Portent — {U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Portent", "{U}", Mtg.CardType.SORCERY)
	card.oracle("Look at the top three cards of target player's library, then put them back in any order. You may have that player shuffle.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
