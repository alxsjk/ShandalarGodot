extends CardScript
## Freyalise's Winds — {2}{G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Freyalise's Winds", "{2}{G}{G}", Mtg.CardType.ENCHANTMENT)
	card.oracle("Whenever a permanent becomes tapped, put a wind counter on it.\nIf a permanent with a wind counter on it would untap during its controller's untap step, remove all wind counters from it instead.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
