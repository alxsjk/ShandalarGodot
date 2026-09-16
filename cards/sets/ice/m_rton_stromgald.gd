extends CardScript
## Márton Stromgald — {2}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Márton Stromgald", "{2}{R}{R}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_supertypes(Mtg.Supertype.LEGENDARY)
	card.with_subtypes(["human","knight"])
	card.oracle("Whenever Márton Stromgald attacks, other attacking creatures get +1/+1 until end of turn for each attacking creature other than Márton Stromgald.\nWhenever Márton Stromgald blocks, other blocking creatures get +1/+1 until end of turn for each blocking creature other than Márton Stromgald.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
