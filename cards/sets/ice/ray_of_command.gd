extends CardScript
## Ray of Command — {3}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Ray of Command", "{3}{U}", Mtg.CardType.INSTANT)
	card.oracle("Untap target creature an opponent controls and gain control of it until end of turn. That creature gains haste until end of turn. When you lose control of the creature, tap it.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
