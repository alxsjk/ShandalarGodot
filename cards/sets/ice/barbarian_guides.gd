extends CardScript
## Barbarian Guides — {2}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Barbarian Guides", "{2}{R}", Mtg.CardType.CREATURE)
	card.pt(1, 2)
	card.with_subtypes(["human","barbarian"])
	card.oracle("{2}{R}, {T}: Choose a land type. Target creature you control gains snow landwalk of the chosen type until end of turn. Return that creature to its owner's hand at the beginning of the next end step. (It can't be blocked as long as defending player controls a snow land of that type.)")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
