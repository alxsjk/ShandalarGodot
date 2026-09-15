extends CardScript
## Drift of the Dead — {3}{B} — optional Pack 3 (ice).
## Trusted game code; the ZIP contains no scripts.

func build() -> CardData:
	var card := CardData.new("Drift of the Dead", "{3}{B}", Mtg.CardType.CREATURE)
	card.pt(0, 0)
	card.with_subtypes(["wall"])
	card.with_keywords([Mtg.Keyword.DEFENDER])
	card.oracle("Defender (This creature can't attack.)\nDrift of the Dead's power and toughness are each equal to the number of snow lands you control.")
	return load("res://cards/sets/ice/_rules.gd").apply(card)
