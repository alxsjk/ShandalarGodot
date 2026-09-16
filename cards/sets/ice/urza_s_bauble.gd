extends CardScript
## Urza's Bauble — {0} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Urza's Bauble", "{0}", Mtg.CardType.ARTIFACT)
	card.oracle("{T}, Sacrifice this artifact: Look at a card at random in target player's hand. You draw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
