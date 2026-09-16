extends CardScript
## Enduring Renewal — {2}{W}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Enduring Renewal", "{2}{W}{W}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Play with your hand revealed.\nIf you would draw a card, reveal the top card of your library instead. If it's a creature card, put it into your graveyard. Otherwise, draw a card.\nWhenever a creature is put into your graveyard from the battlefield, return it to your hand.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
