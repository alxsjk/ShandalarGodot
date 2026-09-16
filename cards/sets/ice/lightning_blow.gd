extends CardScript
## Lightning Blow — {1}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Lightning Blow", "{1}{W}", Mtg.CardType.INSTANT)
	card.oracle("Target creature gains first strike until end of turn.\nDraw a card at the beginning of the next turn's upkeep.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
