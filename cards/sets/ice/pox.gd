extends CardScript
## Pox — {B}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Pox", "{B}{B}{B}", Mtg.CardType.SORCERY)
	card.oracle("Each player loses a third of their life, then discards a third of the cards in their hand, then sacrifices a third of the creatures they control of their choice, then sacrifices a third of the lands they control of their choice. Round up each time.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
