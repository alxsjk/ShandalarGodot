extends CardScript
## Jokulhaups — {4}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Jokulhaups", "{4}{R}{R}", Mtg.CardType.SORCERY)
	card.oracle("Destroy all artifacts, creatures, and lands. They can't be regenerated.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
