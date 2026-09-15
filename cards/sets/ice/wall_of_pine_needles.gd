extends CardScript
## Wall of Pine Needles — {3}{G} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Wall of Pine Needles", "{3}{G}", Mtg.CardType.CREATURE)
	card.pt(3, 3)
	card.with_subtypes(["plant","wall"])
	card.with_keywords([Mtg.Keyword.DEFENDER])
	card.oracle("Defender (This creature can't attack.)\n{G}: Regenerate this creature.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
