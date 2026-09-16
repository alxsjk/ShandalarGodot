extends CardScript
## Word of Command — a bounded digital adaptation of controlling a player.
## SIMPLIFIED: controlling the opponent through playing and resolving their
## chosen card becomes choosing an eligible nonland card to discard; see
## docs/simplified-cards.md.


func build() -> CardData:
	return CardData.new("Word of Command", "{B}{B}", Mtg.CardType.INSTANT) \
		.spell(ChosenDiscardEffect.new(1).nonland_only()) \
		.oracle("Digital adaptation — Target opponent reveals the nonland cards "
			+ "in their hand. Choose one. That player discards that card.")
