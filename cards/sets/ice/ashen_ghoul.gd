extends CardScript
## Ashen Ghoul — {3}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Ashen Ghoul", "{3}{B}", Mtg.CardType.CREATURE)
	card.pt(3, 1)
	card.with_subtypes(["zombie"])
	card.with_keywords([Mtg.Keyword.HASTE])
	card.oracle("Haste\n{B}: Return this card from your graveyard to the battlefield. Activate only during your upkeep and only if three or more creature cards are above this card.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
