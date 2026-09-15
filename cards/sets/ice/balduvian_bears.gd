extends CardScript
## Balduvian Bears — {1}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Balduvian Bears", "{1}{G}", Mtg.CardType.CREATURE)
	card.pt(2, 2)
	card.with_subtypes(["bear"])
	card.oracle("")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
