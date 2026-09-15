extends CardScript
## Melee — {4}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Melee", "{4}{R}", Mtg.CardType.INSTANT)
	card.oracle("Cast this spell only during combat on your turn before blockers are declared.\nYou choose which creatures block this combat and how those creatures block.\nWhenever a creature attacks and isn't blocked this combat, untap it and remove it from combat.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
