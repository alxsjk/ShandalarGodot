extends CardScript
## Pit Trap — {2} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Pit Trap", "{2}", Mtg.CardType.ARTIFACT)
	card.oracle("{2}, {T}, Sacrifice this artifact: Destroy target attacking creature without flying. It can't be regenerated.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
