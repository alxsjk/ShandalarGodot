extends CardScript
## Sulfurous Springs — no mana cost — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Sulfurous Springs", "", Mtg.CardType.LAND)
	card.oracle("{T}: Add {C}.\n{T}: Add {B} or {R}. This land deals 1 damage to you.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
