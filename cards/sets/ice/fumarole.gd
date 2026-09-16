extends CardScript
## Fumarole — {3}{B}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Fumarole", "{3}{B}{R}", Mtg.CardType.SORCERY)
	card.oracle("As an additional cost to cast this spell, pay 3 life.\nDestroy target creature and target land.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
