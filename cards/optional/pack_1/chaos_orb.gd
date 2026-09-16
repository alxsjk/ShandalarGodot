extends CardScript
## Chaos Orb — a bounded digital adaptation of the dexterity card.
## SIMPLIFIED: physical flipping and touched permanents become one uniformly
## random opposing nontoken permanent; see docs/simplified-cards.md.


func build() -> CardData:
	var effect := RandomDestroyEffect.new(1).nontoken_only() \
		.while_source_remains().on_won_coin_flip().then_destroy_source()
	return CardData.new("Chaos Orb", "{2}", Mtg.CardType.ARTIFACT) \
		.activated(ActivatedAbility.new("{1}", true, [effect],
			"{1}, {T}: Flip a coin. If you win, destroy a random opposing "
			+ "nontoken permanent. Then destroy Chaos Orb.")) \
		.oracle("Digital adaptation — {1}, {T}: Flip a coin. If you win, "
			+ "destroy a random opposing nontoken permanent. Then destroy Chaos Orb.")
