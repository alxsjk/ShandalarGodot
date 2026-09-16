extends CardScript
## Karplusan Yeti — {3}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Karplusan Yeti", "{3}{R}{R}", Mtg.CardType.CREATURE)
	card.pt(3, 3)
	card.with_subtypes(["yeti"])
	card.oracle("{T}: This creature deals damage equal to its power to target creature. That creature deals damage equal to its power to this creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
