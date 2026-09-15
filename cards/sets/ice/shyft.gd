extends CardScript
## Shyft — {4}{U} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Shyft", "{4}{U}", Mtg.CardType.CREATURE)
	card.pt(4, 2)
	card.with_subtypes(["shapeshifter"])
	card.oracle("At the beginning of your upkeep, you may have this creature become the color or colors of your choice. (This effect lasts indefinitely.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
