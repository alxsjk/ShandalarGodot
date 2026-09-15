extends CardScript
## Leshrac's Sigil — {B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Leshrac's Sigil", "{B}{B}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Whenever an opponent casts a green spell, you may pay {B}{B}. If you do, look at that player's hand and choose a card from it. The player discards that card.\n{B}{B}: Return this enchantment to its owner's hand.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
