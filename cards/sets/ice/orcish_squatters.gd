extends CardScript
## Orcish Squatters — {4}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Orcish Squatters", "{4}{R}", Mtg.CardType.CREATURE)
	card.pt(2, 3)
	card.with_subtypes(["orc"])
	card.oracle("Whenever this creature attacks and isn't blocked, you may gain control of target land defending player controls for as long as you control this creature. If you do, this creature assigns no combat damage this turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
