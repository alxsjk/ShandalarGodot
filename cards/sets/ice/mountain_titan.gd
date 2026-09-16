extends CardScript
## Mountain Titan — {2}{B}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Mountain Titan", "{2}{B}{R}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["giant"])
	card.oracle("{1}{R}{R}: Until end of turn, whenever you cast a black spell, put a +1/+1 counter on this creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
