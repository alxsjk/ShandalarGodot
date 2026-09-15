extends CardScript
## Curse of Marit Lage — {3}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Curse of Marit Lage", "{3}{R}{R}", Mtg.CardType.ENCHANTMENT)
	card.oracle("When this enchantment enters, tap all Islands.\nIslands don't untap during their controllers' untap steps.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
