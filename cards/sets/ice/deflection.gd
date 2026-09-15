extends CardScript
## Deflection — {3}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Deflection", "{3}{U}", Mtg.CardType.INSTANT)
	card.oracle("Change the target of target spell with a single target.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
