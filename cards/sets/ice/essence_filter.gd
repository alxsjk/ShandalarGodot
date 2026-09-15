extends CardScript
## Essence Filter — {1}{G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Essence Filter", "{1}{G}{G}", Mtg.CardType.SORCERY)
	card.oracle("Destroy all enchantments or all nonwhite enchantments.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
