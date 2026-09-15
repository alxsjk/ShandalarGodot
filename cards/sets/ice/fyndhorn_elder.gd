extends CardScript
## Fyndhorn Elder — {2}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Fyndhorn Elder", "{2}{G}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["elf","druid"])
	card.oracle("{T}: Add {G}{G}.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
