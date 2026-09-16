extends CardScript
## Bone Shaman — {2}{R}{R} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Bone Shaman", "{2}{R}{R}", Mtg.CardType.CREATURE)
	card.pt(3, 3)
	card.with_subtypes(["giant","shaman"])
	card.oracle("{B}: Until end of turn, this creature gains \"Creatures dealt damage by this creature this turn can't be regenerated this turn.\"")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
