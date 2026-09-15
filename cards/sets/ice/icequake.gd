extends CardScript
## Icequake — {1}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Icequake", "{1}{B}{B}", Mtg.CardType.SORCERY)
	card.oracle("Destroy target land. If that land was a snow land, Icequake deals 1 damage to that land's controller.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
