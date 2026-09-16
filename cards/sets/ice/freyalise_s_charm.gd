extends CardScript
## Freyalise's Charm — {G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Freyalise's Charm", "{G}{G}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Whenever an opponent casts a black spell, you may pay {G}{G}. If you do, you draw a card.\n{G}{G}: Return this enchantment to its owner's hand.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
