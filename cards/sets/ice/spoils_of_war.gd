extends CardScript
## Spoils of War — {X}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Spoils of War", "{X}{B}", Mtg.CardType.SORCERY)
	card.oracle("X is the number of artifact and/or creature cards in an opponent's graveyard as you cast this spell.\nDistribute X +1/+1 counters among any number of target creatures.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
