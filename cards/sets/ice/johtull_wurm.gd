extends CardScript
## Johtull Wurm — {5}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Johtull Wurm", "{5}{G}", Mtg.CardType.CREATURE)
	card.pt(6, 6)
	card.with_subtypes(["wurm"])
	card.oracle("Whenever this creature becomes blocked, it gets -2/-1 until end of turn for each creature blocking it beyond the first.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
