extends CardScript
## Wrath of Marit Lage — {3}{U}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Wrath of Marit Lage", "{3}{U}{U}", Mtg.CardType.ENCHANTMENT)
	card.oracle("When this enchantment enters, tap all red creatures.\nRed creatures don't untap during their controllers' untap steps.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
