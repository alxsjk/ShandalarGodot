extends CardScript
## Tarpan — {G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Tarpan", "{G}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["horse"])
	card.oracle("When this creature dies, you gain 1 life.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
