extends CardScript
## Whiteout — {1}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Whiteout", "{1}{G}", Mtg.CardType.INSTANT)
	card.oracle("All creatures lose flying until end of turn.\nSacrifice a snow land: Return this card from your graveyard to your hand.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
