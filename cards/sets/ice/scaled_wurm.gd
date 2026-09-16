extends CardScript
## Scaled Wurm — {7}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Scaled Wurm", "{7}{G}", Mtg.CardType.CREATURE)
	card.pt(7, 6)
	card.with_subtypes(["wurm"])
	card.oracle("")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
