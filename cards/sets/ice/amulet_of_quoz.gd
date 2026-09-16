extends CardScript
## Amulet of Quoz — {6} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Amulet of Quoz", "{6}", Mtg.CardType.ARTIFACT)
	card.oracle("Remove this card from your deck before playing if you're not playing for ante.\n{T}, Sacrifice this artifact: Target opponent may ante the top card of their library. If they don't, you flip a coin. If you win the flip, that player loses the game. If you lose the flip, you lose the game. Activate only during your upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
