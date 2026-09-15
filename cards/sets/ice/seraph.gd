extends CardScript
## Seraph — {6}{W} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Seraph", "{6}{W}", Mtg.CardType.CREATURE)
	card.pt(4, 4)
	card.with_subtypes(["angel"])
	card.with_keywords([Mtg.Keyword.FLYING])
	card.oracle("Flying\nWhenever a creature dealt damage by this creature this turn dies, put that card onto the battlefield under your control at the beginning of the next end step. Sacrifice the creature when you lose control of this creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
