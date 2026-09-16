extends CardScript
## Shambling Strider — {4}{G}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Shambling Strider", "{4}{G}{G}", Mtg.CardType.CREATURE)
	card.pt(5, 5)
	card.with_subtypes(["yeti"])
	card.oracle("{R}{G}: This creature gets +1/-1 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
