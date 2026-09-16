extends CardScript
## Chaos Lord — {4}{R}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Chaos Lord", "{4}{R}{R}{R}", Mtg.CardType.CREATURE)
	card.pt(7, 7)
	card.with_subtypes(["human"])
	card.with_keywords([Mtg.Keyword.FIRST_STRIKE])
	card.oracle("First strike\nAt the beginning of your upkeep, target opponent gains control of this creature if the number of permanents is even.\nThis creature can attack as though it had haste unless it entered this turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
