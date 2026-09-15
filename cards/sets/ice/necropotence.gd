extends CardScript
## Necropotence — {B}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Necropotence", "{B}{B}{B}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Skip your draw step.\nWhenever you discard a card, exile that card from your graveyard.\nPay 1 life: Exile the top card of your library face down. Put that card into your hand at the beginning of your next end step.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
