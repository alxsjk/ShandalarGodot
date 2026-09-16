extends CardScript
## Brushland — no mana cost — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Brushland", "", Mtg.CardType.LAND)
	card.oracle("{T}: Add {C}.\n{T}: Add {G} or {W}. This land deals 1 damage to you.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
