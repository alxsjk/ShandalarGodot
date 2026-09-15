extends CardScript
## Essence Vortex — {1}{U}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Essence Vortex", "{1}{U}{B}", Mtg.CardType.INSTANT)
	card.oracle("Destroy target creature unless its controller pays life equal to its toughness. A creature destroyed this way can't be regenerated.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
