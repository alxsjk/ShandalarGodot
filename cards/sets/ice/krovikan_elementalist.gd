extends CardScript
## Krovikan Elementalist — {B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Krovikan Elementalist", "{B}{B}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["human","wizard"])
	card.oracle("{2}{R}: Target creature gets +1/+0 until end of turn.\n{U}{U}: Target creature you control gains flying until end of turn. Sacrifice it at the beginning of the next end step.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
