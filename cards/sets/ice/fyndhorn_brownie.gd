extends CardScript
## Fyndhorn Brownie — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Fyndhorn Brownie", "{2}{G}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["ouphe"])
	card.oracle("{2}{G}, {T}: Untap target creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
