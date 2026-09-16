extends CardScript
## Soul Barrier — {2}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Soul Barrier", "{2}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Whenever an opponent casts a creature spell, this enchantment deals 2 damage to that player unless they pay {2}.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
