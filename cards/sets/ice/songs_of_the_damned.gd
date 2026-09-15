extends CardScript
## Songs of the Damned — {B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Songs of the Damned", "{B}", Mtg.CardType.INSTANT)
	card.oracle("Add {B} for each creature card in your graveyard.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
