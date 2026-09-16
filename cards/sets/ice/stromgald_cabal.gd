extends CardScript
## Stromgald Cabal — {1}{B}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Stromgald Cabal", "{1}{B}{B}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["human","knight"])
	card.oracle("{T}, Pay 1 life: Counter target white spell.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
