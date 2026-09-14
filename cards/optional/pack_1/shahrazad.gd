extends CardScript
## Shahrazad — a bounded digital adaptation of the printed subgame.
## SIMPLIFIED: the complete Magic subgame becomes one coin flip; see
## docs/simplified-cards.md.


func build() -> CardData:
	return CardData.new("Shahrazad", "{W}{W}", Mtg.CardType.SORCERY) \
		.spell(CoinFlipLifeLossEffect.new()) \
		.oracle("Digital adaptation — Flip a coin. The loser loses half their "
			+ "life, rounded up.")
