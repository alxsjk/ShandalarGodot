extends CardScript
## Elemental Augury — {U}{B}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Elemental Augury", "{U}{B}{R}", Mtg.CardType.ENCHANTMENT)
	card.oracle("{3}: Look at the top three cards of target player's library, then put them back in any order.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
