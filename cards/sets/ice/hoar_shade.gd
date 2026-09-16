extends CardScript
## Hoar Shade — {3}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Hoar Shade", "{3}{B}", Mtg.CardType.CREATURE)
	card.pt(1, 2)
	card.with_subtypes(["shade"])
	card.oracle("{B}: This creature gets +1/+1 until end of turn.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
