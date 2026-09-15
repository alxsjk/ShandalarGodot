extends CardScript
## Arcum's Weathervane — {2} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Arcum's Weathervane", "{2}", Mtg.CardType.ARTIFACT)
	card.oracle("{2}, {T}: Target snow land is no longer snow.\n{2}, {T}: Target nonsnow basic land becomes snow.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
