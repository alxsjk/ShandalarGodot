extends CardScript
## Order of the Sacred Torch — {1}{W}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Order of the Sacred Torch", "{1}{W}{W}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["human","knight"])
	card.oracle("{T}, Pay 1 life: Counter target black spell.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
