extends CardScript
## Falling Star — a bounded digital adaptation of the dexterity card.
## SIMPLIFIED: the physical flip and touched area become chosen creatures with
## one independent coin flip per creature; see docs/simplified-cards.md.


func build() -> CardData:
	return CardData.new("Falling Star", "{2}{R}", Mtg.CardType.SORCERY) \
		.spell(CoinFlipDamageEffect.new(3, true).target_one_or_two()) \
		.oracle("Digital adaptation — Choose one or two target creatures. "
			+ "Flip a coin for each. For each flip you win, Falling Star deals "
			+ "3 damage to that creature, then taps it if it survives.")
