extends CardScript
## Fyndhorn Elves — {G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Fyndhorn Elves", "{G}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["elf","druid"])
	card.oracle("{T}: Add {G}.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
