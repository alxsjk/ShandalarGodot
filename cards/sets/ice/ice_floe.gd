extends CardScript
## Ice Floe — no mana cost — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Ice Floe", "", Mtg.CardType.LAND)
	card.oracle("You may choose not to untap this land during your untap step.\n{T}: Tap target creature without flying that's attacking you. It doesn't untap during its controller's untap step for as long as this land remains tapped.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
