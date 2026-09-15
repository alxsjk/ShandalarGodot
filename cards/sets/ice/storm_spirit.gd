extends CardScript
## Storm Spirit — {3}{G}{W}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Storm Spirit", "{3}{G}{W}{U}", Mtg.CardType.CREATURE)
	card.pt(3, 3)
	card.with_subtypes(["elemental","spirit"])
	card.with_keywords([Mtg.Keyword.FLYING])
	card.oracle("Flying\n{T}: This creature deals 2 damage to target creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
