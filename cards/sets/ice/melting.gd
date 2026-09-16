extends CardScript
## Melting — {3}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Melting", "{3}{R}", Mtg.CardType.ENCHANTMENT)
	card.oracle("All lands are no longer snow.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
