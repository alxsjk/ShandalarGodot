extends CardScript
## Whalebone Glider — {2} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Whalebone Glider", "{2}", Mtg.CardType.ARTIFACT)
	card.oracle("{2}, {T}: Target creature with power 3 or less gains flying until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
