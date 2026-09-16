extends CardScript
## Jester's Cap — {4} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Jester's Cap", "{4}", Mtg.CardType.ARTIFACT)
	card.oracle("{2}, {T}, Sacrifice this artifact: Search target player's library for three cards and exile them. Then that player shuffles.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
