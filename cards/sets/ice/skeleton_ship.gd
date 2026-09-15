extends CardScript
## Skeleton Ship — {3}{U}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Skeleton Ship", "{3}{U}{B}", Mtg.CardType.CREATURE)
	card.pt(0, 3)
	card.with_supertypes(Mtg.Supertype.LEGENDARY)
	card.with_subtypes(["skeleton"])
	card.oracle("When you control no Islands, sacrifice Skeleton Ship.\n{T}: Put a -1/-1 counter on target creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
