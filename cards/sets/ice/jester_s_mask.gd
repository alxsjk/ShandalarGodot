extends CardScript
## Jester's Mask — {5} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Jester's Mask", "{5}", Mtg.CardType.ARTIFACT)
	card.oracle("This artifact enters tapped.\n{1}, {T}, Sacrifice this artifact: Target opponent puts the cards from their hand on top of their library. Search that player's library for that many cards. That player puts those cards into their hand, then shuffles.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
