extends CardScript
## Stench of Evil — {2}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Stench of Evil", "{2}{B}{B}", Mtg.CardType.SORCERY)
	card.oracle("Destroy all Plains. For each land destroyed this way, Stench of Evil deals 1 damage to that land's controller unless they pay {2}.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
