extends CardScript
## Goblin Mutant — {2}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Goblin Mutant", "{2}{R}{R}", Mtg.CardType.CREATURE)
	card.pt(5, 3)
	card.with_subtypes(["goblin","mutant"])
	card.with_keywords([Mtg.Keyword.TRAMPLE])
	card.oracle("Trample\nThis creature can't attack if defending player controls an untapped creature with power 3 or greater.\nThis creature can't block creatures with power 3 or greater.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
