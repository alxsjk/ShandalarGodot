extends CardScript
## Infinite Hourglass — {4} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Infinite Hourglass", "{4}", Mtg.CardType.ARTIFACT)
	card.oracle("At the beginning of your upkeep, put a time counter on this artifact.\nAll creatures get +1/+0 for each time counter on this artifact.\n{3}: Remove a time counter from this artifact. Any player may activate this ability but only during any upkeep step.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
