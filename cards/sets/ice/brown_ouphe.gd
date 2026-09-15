extends CardScript
## Brown Ouphe — {G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Brown Ouphe", "{G}", Mtg.CardType.CREATURE)
	card.pt(1, 1)
	card.with_subtypes(["ouphe"])
	card.oracle("{1}{G}, {T}: Counter target activated ability from an artifact source. (Mana abilities can't be targeted.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
