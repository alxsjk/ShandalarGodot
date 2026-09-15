extends CardScript
## Fiery Justice — {R}{G}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Fiery Justice", "{R}{G}{W}", Mtg.CardType.SORCERY)
	card.oracle("Fiery Justice deals 5 damage divided as you choose among any number of targets. Target opponent gains 5 life.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
